#!/bin/bash

# Script de despliegue automatizado para Tomcat
# Sistema LogiTrack - Gestión de Bodegas

set -e  # Salir si hay algún error

echo "=========================================="
echo "  LogiTrack - Despliegue en Tomcat"
echo "=========================================="
echo ""

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 1. Construir el frontend
echo -e "${BLUE}[1/4] Construyendo frontend...${NC}"
cd frontend
npm install --silent
npm run build
cd ..
echo -e "${GREEN}✓ Frontend construido${NC}"
echo ""

# 2. Generar el WAR con Maven
echo -e "${BLUE}[2/4] Generando archivo WAR...${NC}"
mvn clean package -DskipTests -q
echo -e "${GREEN}✓ WAR generado: target/logitrack-0.0.1-SNAPSHOT.war${NC}"
echo ""

# 3. Verificar Tomcat
echo -e "${BLUE}[3/4] Verificando Tomcat...${NC}"
if [ -z "$CATALINA_HOME" ]; then
    echo -e "${RED}✗ Error: CATALINA_HOME no está configurado${NC}"
    echo "Por favor, configura la variable de entorno CATALINA_HOME:"
    echo "  export CATALINA_HOME=/ruta/a/tomcat"
    exit 1
fi

if [ ! -d "$CATALINA_HOME/webapps" ]; then
    echo -e "${RED}✗ Error: $CATALINA_HOME/webapps no existe${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Tomcat encontrado en: $CATALINA_HOME${NC}"
echo ""

# 4. Desplegar WAR
echo -e "${BLUE}[4/4] Desplegando en Tomcat...${NC}"

# Detener Tomcat si está corriendo
if [ -f "$CATALINA_HOME/bin/shutdown.sh" ]; then
    echo "  - Deteniendo Tomcat..."
    $CATALINA_HOME/bin/shutdown.sh 2>/dev/null || true
    sleep 3
fi

# Limpiar despliegue anterior
if [ -d "$CATALINA_HOME/webapps/logitrack" ]; then
    echo "  - Eliminando despliegue anterior..."
    rm -rf "$CATALINA_HOME/webapps/logitrack"
fi

if [ -f "$CATALINA_HOME/webapps/logitrack.war" ]; then
    rm -f "$CATALINA_HOME/webapps/logitrack.war"
fi

# Copiar nuevo WAR
echo "  - Copiando WAR a Tomcat..."
cp target/logitrack-0.0.1-SNAPSHOT.war "$CATALINA_HOME/webapps/logitrack.war"

# Iniciar Tomcat
echo "  - Iniciando Tomcat..."
$CATALINA_HOME/bin/startup.sh

echo -e "${GREEN}✓ Despliegue completado${NC}"
echo ""

echo "=========================================="
echo "  Despliegue exitoso!"
echo "=========================================="
echo ""
echo "La aplicación estará disponible en:"
echo "  - Frontend:  http://localhost:8080/logitrack/"
echo "  - API:       http://localhost:8080/logitrack/api/"
echo "  - Swagger:   http://localhost:8080/logitrack/swagger-ui.html"
echo ""
echo "Para ver los logs:"
echo "  tail -f $CATALINA_HOME/logs/catalina.out"
echo ""
echo "Para detener Tomcat:"
echo "  $CATALINA_HOME/bin/shutdown.sh"
echo ""
