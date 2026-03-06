@echo off
REM Script para configurar Azure Container Registry en Windows
REM Uso: setup-azure.bat

echo ========================================
echo 🚀 Configuracion de Azure Container Registry
echo ========================================
echo.

REM Variables (personaliza estos valores)
set RESOURCE_GROUP=rg-workshop-quarkus
set ACR_NAME=acrworkshopquarkus
set LOCATION=eastus

echo Configuracion:
echo   - Resource Group: %RESOURCE_GROUP%
echo   - ACR Name: %ACR_NAME%
echo   - Location: %LOCATION%
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

REM Login a Azure
echo 🔑 Iniciando sesion en Azure...
call az login
if %ERRORLEVEL% NEQ 0 exit /b 1

REM Crear Resource Group
echo.
echo 📦 Creando Resource Group...
call az group create --name %RESOURCE_GROUP% --location %LOCATION%
echo ✅ Resource Group creado
echo.

REM Crear Azure Container Registry
echo 🐳 Creando Azure Container Registry...
call az acr create --resource-group %RESOURCE_GROUP% --name %ACR_NAME% --sku Basic --location %LOCATION%
echo ✅ ACR creado
echo.

REM Habilitar admin user
echo 👤 Habilitando usuario administrador...
call az acr update --name %ACR_NAME% --admin-enabled true
echo ✅ Usuario administrador habilitado
echo.

REM Obtener credenciales
echo 🔐 Obteniendo credenciales...
for /f "tokens=*" %%i in ('az acr show --name %ACR_NAME% --query loginServer --output tsv') do set LOGIN_SERVER=%%i
for /f "tokens=*" %%i in ('az acr credential show --name %ACR_NAME% --query username --output tsv') do set USERNAME=%%i
for /f "tokens=*" %%i in ('az acr credential show --name %ACR_NAME% --query "passwords[0].value" --output tsv') do set PASSWORD=%%i

echo.
echo ========================================
echo Credenciales del ACR:
echo ========================================
echo Login Server: %LOGIN_SERVER%
echo Username: %USERNAME%
echo Password: %PASSWORD%
echo.

REM Guardar en archivo .env
echo 💾 Guardando credenciales en .env...
(
echo # Azure Container Registry Credentials
echo AZURE_REGISTRY_LOGIN_SERVER=%LOGIN_SERVER%
echo AZURE_REGISTRY_USERNAME=%USERNAME%
echo AZURE_REGISTRY_PASSWORD=%PASSWORD%
) > .env

echo ✅ Credenciales guardadas en .env
echo.

REM Instrucciones para GitHub Secrets
echo ========================================
echo 📝 Configurar GitHub Secrets:
echo ========================================
echo.
echo Ve a tu repositorio en GitHub:
echo Settings → Secrets and variables → Actions → New repository secret
echo.
echo Crea los siguientes secrets:
echo.
echo 1. AZURE_REGISTRY_LOGIN_SERVER
echo    Valor: %LOGIN_SERVER%
echo.
echo 2. AZURE_REGISTRY_USERNAME
echo    Valor: %USERNAME%
echo.
echo 3. AZURE_REGISTRY_PASSWORD
echo    Valor: %PASSWORD%
echo.

REM Test login
echo 🧪 Probando login a ACR...
call az acr login --name %ACR_NAME%
if %ERRORLEVEL% EQU 0 (
    echo ✅ Login exitoso
) else (
    echo ❌ Error en login
)

echo.
echo ========================================
echo ✨ ¡Configuracion completada!
echo ========================================
echo.
echo Proximos pasos:
echo 1. Configurar GitHub Secrets ^(ver arriba^)
echo 2. Push tu codigo a GitHub
echo 3. El workflow se ejecutara automaticamente
echo.

pause
