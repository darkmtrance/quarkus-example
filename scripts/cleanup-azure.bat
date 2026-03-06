@echo off
REM Script para limpiar recursos de Azure en Windows
REM Uso: cleanup-azure.bat

echo ===========================================
echo 🗑️ Limpieza de Recursos de Azure
echo ===========================================
echo.

set RESOURCE_GROUP=rg-workshop-quarkus
set ACR_NAME=acrworkshopquarkus

echo ⚠️ ADVERTENCIA: Esta accion eliminara todos los recursos
echo.
echo Recursos a eliminar:
echo   - Resource Group: %RESOURCE_GROUP%
echo   - Azure Container Registry: %ACR_NAME%
echo   - Todas las imagenes de contenedor
echo.

set /p CONFIRM="¿Estas seguro? (escribe SI para confirmar): "

if not "%CONFIRM%"=="SI" (
    echo.
    echo Operacion cancelada
    exit /b 0
)

echo.
echo 🔑 Iniciando sesion en Azure...
call az login
if %ERRORLEVEL% NEQ 0 exit /b 1

echo.
echo 📋 Listando recursos actuales...
call az resource list --resource-group %RESOURCE_GROUP% --output table

echo.
echo 🗑️ Eliminando Resource Group...
call az group delete --name %RESOURCE_GROUP% --yes --no-wait

echo.
echo ✅ Solicitud de eliminacion enviada
echo.
echo La eliminacion se esta ejecutando en segundo plano.
echo Puede tomar varios minutos completarse.
echo.
echo Para verificar el estado:
echo   az group show --name %RESOURCE_GROUP%
echo.

REM Limpiar archivos locales
echo 🧹 Limpiando archivos locales...
if exist .env (
    del .env
    echo   - Removed .env
)

echo.
echo ===========================================
echo ✨ Limpieza completada
echo ===========================================
echo.

pause
