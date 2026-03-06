#!/bin/bash

# Script para crear Azure Container Apps con SKU Consumption (más básico)
# Uso: ./setup-container-apps.sh

set -e

echo "🚀 Configuración de Azure Container Apps"
echo "========================================="
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Variables (personaliza estos valores)
RESOURCE_GROUP="rg-workshop-quarkus"
LOCATION="eastus"
ACR_NAME="acrworkshopquarkus"
ENVIRONMENT_NAME="env-workshop-quarkus"
CONTAINER_APP_NAME="ca-hello-api"
IMAGE_NAME="hello-api"
IMAGE_TAG="latest"

echo -e "${YELLOW}ℹ️  Configuración:${NC}"
echo "  - Resource Group: $RESOURCE_GROUP"
echo "  - Location: $LOCATION"
echo "  - ACR Name: $ACR_NAME"
echo "  - Environment: $ENVIRONMENT_NAME"
echo "  - Container App: $CONTAINER_APP_NAME"
echo "  - Imagen: $IMAGE_NAME:$IMAGE_TAG"
echo ""

# Verificar Azure CLI
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI no está instalado${NC}"
    echo "Instala desde: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

echo -e "${GREEN}✅ Azure CLI encontrado${NC}"
echo ""

# Verificar que el Resource Group existe
echo "🔍 Verificando Resource Group..."
if ! az group exists --name "$RESOURCE_GROUP" | grep -q true; then
    echo -e "${RED}❌ Resource Group no existe: $RESOURCE_GROUP${NC}"
    echo "Ejecuta primero: ./setup-azure.sh"
    exit 1
fi
echo -e "${GREEN}✅ Resource Group encontrado${NC}"
echo ""

# Verificar que el ACR existe
echo "🔍 Verificando Azure Container Registry..."
if ! az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    echo -e "${RED}❌ ACR no encontrado: $ACR_NAME${NC}"
    echo "Ejecuta primero: ./setup-azure.sh"
    exit 1
fi
echo -e "${GREEN}✅ ACR encontrado${NC}"
echo ""

# Obtener Login Server del ACR
echo "📋 Obteniendo datos del ACR..."
LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer --output tsv)
FULL_IMAGE="${LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"
echo -e "${GREEN}Imagen completa:${NC} $FULL_IMAGE"
echo ""

# Crear Container Apps Environment
echo "🏗️  Creando Container Apps Environment..."
if az containerapp env create \
    --name "$ENVIRONMENT_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" &> /dev/null; then
    echo -e "${GREEN}✅ Environment creado: $ENVIRONMENT_NAME${NC}"
else
    echo -e "${YELLOW}⚠️  Environment ya existe${NC}"
fi
echo ""

# Obtener credenciales del ACR
echo "🔐 Obteniendo credenciales del ACR..."
REGISTRY_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username --output tsv)
REGISTRY_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" --output tsv)
echo -e "${GREEN}✅ Credenciales obtenidas${NC}"
echo ""

# Crear Container App
echo "🐳 Creando Container App..."
az containerapp create \
    --name "$CONTAINER_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --environment "$ENVIRONMENT_NAME" \
    --image "$FULL_IMAGE" \
    --target-port 8080 \
    --ingress external \
    --registry-server "$LOGIN_SERVER" \
    --registry-username "$REGISTRY_USERNAME" \
    --registry-password "$REGISTRY_PASSWORD" \
    --cpu 0.25 \
    --memory 0.5Gi \
    --min-replicas 0 \
    --max-replicas 1 \
    --query properties.configuration.ingress.fqdn \
    --output tsv > /tmp/container_app_url.txt

echo -e "${GREEN}✅ Container App creado: $CONTAINER_APP_NAME${NC}"
echo ""

# Obtener URL de acceso
echo "🌐 Información de acceso:"
echo "=========================="
CONTAINER_APP_URL=$(cat /tmp/container_app_url.txt)
echo -e "${GREEN}URL:${NC} https://$CONTAINER_APP_URL"
echo ""

# Guardar información en archivo
echo "💾 Guardando información en .env..."
cat >> .env << EOF

# Azure Container Apps Configuration
AZURE_CONTAINER_APP_NAME=$CONTAINER_APP_NAME
AZURE_CONTAINER_APP_ENVIRONMENT=$ENVIRONMENT_NAME
AZURE_CONTAINER_APP_URL=https://$CONTAINER_APP_URL
AZURE_CONTAINER_APP_IMAGE=$FULL_IMAGE
EOF

echo -e "${GREEN}✅ Información guardada en .env${NC}"
echo ""

# Instrucciones finales
echo "✨ ¡Configuración completada!"
echo "================================"
echo ""
echo "📌 Próximos pasos:"
echo ""
echo "1. Construir la imagen localmente:"
echo "   ./mvnw clean package -Dquarkus.container-image.build=true"
echo ""
echo "2. Hacer push a ACR:"
echo "   az acr build --registry $ACR_NAME --image $IMAGE_NAME:$IMAGE_TAG ."
echo ""
echo "3. Actualizar el Container App después de hacer push de nueva imagen:"
echo "   az containerapp update --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP"
echo ""
echo "4. Ver logs:"
echo "   az containerapp logs show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP -f"
echo ""
echo "5. Eliminar recursos (cuando termines):"
echo "   ./cleanup-azure.sh"
echo ""
