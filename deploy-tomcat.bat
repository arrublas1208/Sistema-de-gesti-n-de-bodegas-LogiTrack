@echo off
setlocal enableextensions

set "SCRIPT_DIR=%~dp0"
echo ==========================================
echo   LogiTrack - Despliegue en Tomcat (Windows)
echo ==========================================
echo.

if not defined JAVA_HOME (
  if exist "C:\Program Files\Java\jdk-21" (
    set "JAVA_HOME=C:\Program Files\Java\jdk-21"
  ) else (
    echo [ERROR] JAVA_HOME no esta definido. Configure JAVA_HOME.
    exit /b 1
  )
)

if not defined CATALINA_HOME (
  if exist "C:\xampp\tomcat" (
    set "CATALINA_HOME=C:\xampp\tomcat"
  ) else (
    echo [ERROR] CATALINA_HOME no esta definido. Configure CATALINA_HOME.
    exit /b 1
  )
)

echo [1/4] Construyendo frontend...
pushd "%SCRIPT_DIR%frontend"
npm install --silent
if errorlevel 1 goto :fail
npm run build
if errorlevel 1 goto :fail
popd
echo OK frontend
echo.

echo [2/4] Generando WAR...
pushd "%SCRIPT_DIR%"
call "%SCRIPT_DIR%mvnw.cmd" clean package -DskipTests
if errorlevel 1 goto :fail
popd
echo OK WAR
echo.

echo [3/4] Desplegando en Tomcat...
set "WAR=%SCRIPT_DIR%target\logitrack-0.0.1-SNAPSHOT.war"
if not exist "%WAR%" (
  echo [ERROR] No se encontro WAR: %WAR%
  exit /b 1
)
copy /Y "%WAR%" "%CATALINA_HOME%\webapps\logitrack.war"
if errorlevel 1 goto :fail
echo OK Copia
echo.

echo [4/4] Reiniciando Tomcat...
call "%CATALINA_HOME%\bin\shutdown.bat"
call "%CATALINA_HOME%\bin\startup.bat"
echo OK Tomcat iniciado
echo.

echo Validacion rapida...
curl -s -o nul -w "HTTP %%%%{http_code}\n" http://localhost:8080/logitrack/ 2>nul
curl -s -o nul -w "HTTP %%%%{http_code}\n" http://localhost:8080/logitrack/swagger-ui/index.html 2>nul

echo Listo.
exit /b 0

:fail
echo [ERROR] Fallo el paso anterior. Revise mensajes.
exit /b 1