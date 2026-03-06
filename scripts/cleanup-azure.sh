#!/bin/bash

# Script para limpiar recursos de Azure
# Uso: ./cleanup-azure.sh

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Variables
RESOURCE_GROUP="rg-workshop-quarkus"
ACR_NAME="acrworkshopquarkus"

echo "==========================================="
echo -e "${RED}🗑️  Limpieza de Recursos de Azure${NC}"
echo "==========================================="
echo ""

echo -e "${YELLOW}⚠️  ADVERTENCIA: Esta acción eliminará todos los recursos${NC}"
echo ""
echo "Recursos a eliminar:"
echo "  - Resource Group: $RESOURCE_GROUP"
echo "  - Azure Container Registry: $ACR_NAME"
echo "  - Todas las imágenes de contenedor"
echo ""

read -p "¿Estás seguro? (escribe 'SI' para confirmar): " CONFIRM

if [ "$CONFIRM" != "SI" ]; then
    echo ""
    echo "Operación cancelada"
    exit 0
fi

echo ""
echo "🔑 Iniciando sesión en Azure..."
az login

echo ""
echo "📋 Listando recursos actuales..."
az resource list --resource-group "$RESOURCE_GROUP" --output table

echo ""
echo "🗑️  Eliminando Resource Group..."
az group delete --name "$RESOURCE_GROUP" --yes --no-wait

echo ""
echo -e "${GREEN}✅ Solicitud de eliminación enviada${NC}"
echo ""
echo "La eliminación se está ejecutando en segundo plano."
echo "Puede tomar varios minutos completarse."
echo ""
echo "Para verificar el estado:"
echo "  az group show --name $RESOURCE_GROUP"
echo ""

# Limpiar archivos locales
echo "🧹 Limpiando archivos locales..."
if [ -f .env ]; then
    rm .env
    echo "  - Removed .env"
fi

echo ""
echo "==========================================="
echo -e "${GREEN}✨ Limpieza completada${NC}"
echo "==========================================="
