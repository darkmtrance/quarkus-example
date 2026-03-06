#!/bin/bash

# Script para configurar Azure Container Registry
# Uso: ./setup-azure.sh

set -e

echo "🚀 Configuración de Azure Container Registry"
echo "=============================================="
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Variables (personaliza estos valores)
RESOURCE_GROUP="rg-workshop-quarkus"
ACR_NAME="acrworkshopquarkus"
LOCATION="eastus"

echo -e "${YELLOW}ℹ️  Configuración:${NC}"
echo "  - Resource Group: $RESOURCE_GROUP"
echo "  - ACR Name: $ACR_NAME"
echo "  - Location: $LOCATION"
echo ""

# Verificar Azure CLI
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI no está instalado${NC}"
    echo "Instala desde: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

echo -e "${GREEN}✅ Azure CLI encontrado${NC}"

# Login a Azure
echo ""
echo "🔑 Iniciando sesión en Azure..."
az login

# Seleccionar suscripción
echo ""
echo "📋 Suscripciones disponibles:"
az account list --output table

echo ""
read -p "Ingresa el ID de la suscripción a usar (Enter para usar la actual): " SUBSCRIPTION_ID

if [ ! -z "$SUBSCRIPTION_ID" ]; then
    az account set --subscription "$SUBSCRIPTION_ID"
    echo -e "${GREEN}✅ Suscripción configurada${NC}"
fi

# Crear Resource Group
echo ""
echo "📦 Creando Resource Group..."
if az group create --name "$RESOURCE_GROUP" --location "$LOCATION" &> /dev/null; then
    echo -e "${GREEN}✅ Resource Group creado: $RESOURCE_GROUP${NC}"
else
    echo -e "${YELLOW}⚠️  Resource Group ya existe${NC}"
fi

# Crear Azure Container Registry
echo ""
echo "🐳 Creando Azure Container Registry..."
if az acr create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$ACR_NAME" \
    --sku Basic \
    --location "$LOCATION" &> /dev/null; then
    echo -e "${GREEN}✅ ACR creado: $ACR_NAME${NC}"
else
    echo -e "${YELLOW}⚠️  ACR ya existe o el nombre no está disponible${NC}"
fi

# Habilitar admin user
echo ""
echo "👤 Habilitando usuario administrador..."
az acr update --name "$ACR_NAME" --admin-enabled true > /dev/null
echo -e "${GREEN}✅ Usuario administrador habilitado${NC}"

# Obtener credenciales
echo ""
echo "🔐 Credenciales del ACR:"
echo "========================"
LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer --output tsv)
USERNAME=$(az acr credential show --name "$ACR_NAME" --query username --output tsv)
PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" --output tsv)

echo -e "${GREEN}Login Server:${NC} $LOGIN_SERVER"
echo -e "${GREEN}Username:${NC} $USERNAME"
echo -e "${GREEN}Password:${NC} $PASSWORD"

# Guardar en archivo .env
echo ""
echo "💾 Guardando credenciales en .env..."
cat > .env << EOF
# Azure Container Registry Credentials
AZURE_REGISTRY_LOGIN_SERVER=$LOGIN_SERVER
AZURE_REGISTRY_USERNAME=$USERNAME
AZURE_REGISTRY_PASSWORD=$PASSWORD
EOF

echo -e "${GREEN}✅ Credenciales guardadas en .env${NC}"

# Instrucciones para GitHub Secrets
echo ""
echo "================================================"
echo -e "${YELLOW}📝 Configurar GitHub Secrets:${NC}"
echo "================================================"
echo ""
echo "Ve a tu repositorio en GitHub:"
echo "Settings → Secrets and variables → Actions → New repository secret"
echo ""
echo "Crea los siguientes secrets:"
echo ""
echo "1. AZURE_REGISTRY_LOGIN_SERVER"
echo "   Valor: $LOGIN_SERVER"
echo ""
echo "2. AZURE_REGISTRY_USERNAME"
echo "   Valor: $USERNAME"
echo ""
echo "3. AZURE_REGISTRY_PASSWORD"
echo "   Valor: $PASSWORD"
echo ""

# Test login
echo ""
echo "🧪 Probando login a ACR..."
if az acr login --name "$ACR_NAME" &> /dev/null; then
    echo -e "${GREEN}✅ Login exitoso${NC}"
else
    echo -e "${RED}❌ Error en login${NC}"
fi

echo ""
echo "================================================"
echo -e "${GREEN}✨ ¡Configuración completada!${NC}"
echo "================================================"
echo ""
echo "Próximos pasos:"
echo "1. Configurar GitHub Secrets (ver arriba)"
echo "2. Push tu código a GitHub"
echo "3. El workflow se ejecutará automáticamente"
echo ""
