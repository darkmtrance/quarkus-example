@echo off
REM Script para crear Azure Container Apps con SKU Consumption (mas basico) en Windows
REM Uso: setup-container-apps.bat

echo ================================================
echo 🚀 Configuracion de Azure Container Apps
echo ================================================
echo.

REM Variables (personaliza estos valores)
set RESOURCE_GROUP=rg-workshop-quarkus
set LOCATION=eastus
set ACR_NAME=acrworkshopquarkus
set ENVIRONMENT_NAME=env-workshop-quarkus
set CONTAINER_APP_NAME=ca-hello-api
set IMAGE_NAME=hello-api
set IMAGE_TAG=latest

echo Configuracion:
echo   - Resource Group: %RESOURCE_GROUP%
echo   - Location: %LOCATION%
echo   - ACR Name: %ACR_NAME%
echo   - Environment: %ENVIRONMENT_NAME%
echo   - Container App: %CONTAINER_APP_NAME%
echo   - Imagen: %IMAGE_NAME%:%IMAGE_TAG%
echo.

REM Verificar Azure CLI
where az >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Azure CLI no esta instalado
    echo Instala desde: https://docs.microsoft.com/cli/azure/install-azure-cli
    exit /b 1
)

echo ✅ Azure CLI encontrado
echo.

REM Verificar que el Resource Group existe
echo 🔍 Verificando Resource Group...
call az group exists --name %RESOURCE_GROUP% > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Resource Group no existe: %RESOURCE_GROUP%
    echo Ejecuta primero: setup-azure.bat
    exit /b 1
)

echo ✅ Resource Group encontrado
echo.

REM Verificar que el ACR existe
echo 🔍 Verificando Azure Container Registry...
call az acr show --name %ACR_NAME% --resource-group %RESOURCE_GROUP% > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ ACR no encontrado: %ACR_NAME%
    echo Ejecuta primero: setup-azure.bat
    exit /b 1
)

echo ✅ ACR encontrado
echo.

REM Obtener Login Server del ACR
echo 📋 Obteniendo datos del ACR...
for /f "tokens=*" %%i in ('az acr show --name %ACR_NAME% --query loginServer --output tsv') do set LOGIN_SERVER=%%i
set FULL_IMAGE=%LOGIN_SERVER%/%IMAGE_NAME%:%IMAGE_TAG%
echo Imagen completa: %FULL_IMAGE%
echo.

REM Crear Container Apps Environment
echo 🏗️  Creando Container Apps Environment...
call az containerapp env create --name %ENVIRONMENT_NAME% --resource-group %RESOURCE_GROUP% --location %LOCATION% > nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ Environment creado: %ENVIRONMENT_NAME%
) else (
    echo ⚠️  Environment ya existe
)
echo.

REM Obtener credenciales del ACR
echo 🔐 Obteniendo credenciales del ACR...
for /f "tokens=*" %%i in ('az acr credential show --name %ACR_NAME% --query username --output tsv') do set REGISTRY_USERNAME=%%i
for /f "tokens=*" %%i in ('az acr credential show --name %ACR_NAME% --query "passwords[0].value" --output tsv') do set REGISTRY_PASSWORD=%%i
echo ✅ Credenciales obtenidas
echo.

REM Crear Container App
echo 🐳 Creando Container App...
call az containerapp create ^
    --name %CONTAINER_APP_NAME% ^
    --resource-group %RESOURCE_GROUP% ^
    --environment %ENVIRONMENT_NAME% ^
    --image %FULL_IMAGE% ^
    --target-port 8080 ^
    --ingress external ^
    --registry-server %LOGIN_SERVER% ^
    --registry-username %REGISTRY_USERNAME% ^
    --registry-password %REGISTRY_PASSWORD% ^
    --cpu 0.25 ^
    --memory 0.5Gi ^
    --min-replicas 0 ^
    --max-replicas 1

if %ERRORLEVEL% EQU 0 (
    echo ✅ Container App creado: %CONTAINER_APP_NAME%
) else (
    echo ❌ Error al crear Container App
    exit /b 1
)

echo.

REM Obtener URL de acceso
echo 🌐 Obteniendo informacion de acceso...
for /f "tokens=*" %%i in ('az containerapp show --name %CONTAINER_APP_NAME% --resource-group %RESOURCE_GROUP% --query properties.configuration.ingress.fqdn --output tsv') do set CONTAINER_APP_URL=%%i

echo.
echo ================================================
echo Informacion de acceso:
echo ================================================
echo URL: https://%CONTAINER_APP_URL%
echo.

REM Guardar informacion en archivo
echo 💾 Guardando informacion en .env...
(
    echo.
    echo # Azure Container Apps Configuration
    echo AZURE_CONTAINER_APP_NAME=%CONTAINER_APP_NAME%
    echo AZURE_CONTAINER_APP_ENVIRONMENT=%ENVIRONMENT_NAME%
    echo AZURE_CONTAINER_APP_URL=https://%CONTAINER_APP_URL%
    echo AZURE_CONTAINER_APP_IMAGE=%FULL_IMAGE%
) >> .env

echo ✅ Informacion guardada en .env
echo.

REM Instrucciones finales
echo ✨ ¡Configuracion completada!
echo ================================================
echo.
echo 📌 Proximos pasos:
echo.
echo 1. Construir la imagen localmente:
echo    mvnw.cmd clean package -Dquarkus.container-image.build=true
echo.
echo 2. Hacer push a ACR:
echo    az acr build --registry %ACR_NAME% --image %IMAGE_NAME%:%IMAGE_TAG% .
echo.
echo 3. Actualizar el Container App despues de hacer push de nueva imagen:
echo    az containerapp update --name %CONTAINER_APP_NAME% --resource-group %RESOURCE_GROUP%
echo.
echo 4. Ver logs:
echo    az containerapp logs show --name %CONTAINER_APP_NAME% --resource-group %RESOURCE_GROUP% -f
echo.
echo 5. Eliminar recursos (cuando termines):
echo    cleanup-azure.bat
echo.
