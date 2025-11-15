#!/bin/bash

# Script completo para construir y desplegar LogiTrack en Tomcat
# Uso: ./build-y-desplegar.sh [CATALINA_HOME]
# Ejemplo: ./build-y-desplegar.sh /opt/tomcat

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Build y Despliegue de LogiTrack${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Verificar Java 17
echo -e "${YELLOW}1. Verificando Java 17...${NC}"
JAVA_VERSION=$(java -version 2>&1 | grep version | awk '{print $3}' | tr -d '"' | cut -d'.' -f1)
if [ "$JAVA_VERSION" -lt 17 ]; then
    echo -e "${RED}ERROR: Se requiere Java 17 o superior${NC}"
    echo -e "${RED}Versión actual: $(java -version 2>&1 | head -n 1)${NC}"
    echo ""
    echo -e "${YELLOW}Para instalar Java 17, ejecuta:${NC}"
    echo "  sudo ./instalar-java17.sh"
    exit 1
fi
echo -e "${GREEN}✓ Java $(java -version 2>&1 | head -n 1 | awk '{print $3}' | tr -d '"')${NC}"
echo ""

# Verificar MySQL
echo -e "${YELLOW}2. Verificando MySQL...${NC}"
if ! systemctl is-active --quiet mysql && ! systemctl is-active --quiet mysqld; then
    echo -e "${RED}⚠ MySQL no está corriendo${NC}"
    echo -e "${YELLOW}Intenta iniciar MySQL con:${NC}"
    echo "  sudo systemctl start mysql"
    echo ""
    read -p "¿Continuar de todos modos? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo -e "${GREEN}✓ MySQL está corriendo${NC}"
fi
echo ""

# Limpiar build anterior
echo -e "${YELLOW}3. Limpiando build anterior...${NC}"
./mvnw clean
echo -e "${GREEN}✓ Limpieza completada${NC}"
echo ""

# Construir proyecto
echo -e "${YELLOW}4. Construyendo WAR (esto puede tomar unos minutos)...${NC}"
./mvnw package -DskipTests
echo -e "${GREEN}✓ WAR construido exitosamente${NC}"
echo ""

# Verificar WAR
WAR_FILE="target/logitrack.war"
if [ ! -f "$WAR_FILE" ]; then
    echo -e "${RED}ERROR: No se encontró el archivo WAR en $WAR_FILE${NC}"
    exit 1
fi

WAR_SIZE=$(du -h "$WAR_FILE" | cut -f1)
echo -e "${GREEN}✓ Archivo WAR: $WAR_FILE ($WAR_SIZE)${NC}"
echo ""

# Verificar variables de entorno
echo -e "${YELLOW}5. Verificando variables de entorno...${NC}"
MISSING_VARS=()
if [ -z "$DB_URL" ]; then MISSING_VARS+=("DB_URL"); fi
if [ -z "$DB_USERNAME" ]; then MISSING_VARS+=("DB_USERNAME"); fi
if [ -z "$DB_PASSWORD" ]; then MISSING_VARS+=("DB_PASSWORD"); fi
if [ -z "$JWT_SECRET" ]; then MISSING_VARS+=("JWT_SECRET"); fi

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠ Las siguientes variables de entorno no están configuradas:${NC}"
    for var in "${MISSING_VARS[@]}"; do
        echo "  - $var"
    done
    echo ""
    echo -e "${YELLOW}Usando valores por defecto de application.properties${NC}"
    echo -e "${YELLOW}Para producción, configura estas variables antes de desplegar.${NC}"
else
    echo -e "${GREEN}✓ Variables de entorno configuradas${NC}"
fi
echo ""

# Despliegue en Tomcat
if [ -n "$1" ]; then
    CATALINA_HOME="$1"
    echo -e "${YELLOW}6. Desplegando en Tomcat...${NC}"

    if [ ! -d "$CATALINA_HOME" ]; then
        echo -e "${RED}ERROR: Directorio CATALINA_HOME no encontrado: $CATALINA_HOME${NC}"
        exit 1
    fi

    WEBAPPS_DIR="$CATALINA_HOME/webapps"
    if [ ! -d "$WEBAPPS_DIR" ]; then
        echo -e "${RED}ERROR: Directorio webapps no encontrado: $WEBAPPS_DIR${NC}"
        exit 1
    fi

    # Detener Tomcat si está corriendo
    if [ -f "$CATALINA_HOME/bin/shutdown.sh" ]; then
        echo "Deteniendo Tomcat..."
        "$CATALINA_HOME/bin/shutdown.sh" 2>/dev/null || true
        sleep 3
    fi

    # Eliminar despliegue anterior
    echo "Eliminando despliegue anterior..."
    rm -rf "$WEBAPPS_DIR/logitrack" "$WEBAPPS_DIR/logitrack.war"

    # Copiar nuevo WAR
    echo "Copiando WAR a Tomcat..."
    cp "$WAR_FILE" "$WEBAPPS_DIR/logitrack.war"

    echo -e "${GREEN}✓ WAR copiado a $WEBAPPS_DIR${NC}"
    echo ""

    # Iniciar Tomcat
    if [ -f "$CATALINA_HOME/bin/startup.sh" ]; then
        echo "Iniciando Tomcat..."
        "$CATALINA_HOME/bin/startup.sh"
        echo -e "${GREEN}✓ Tomcat iniciado${NC}"
        echo ""
        echo -e "${BLUE}=========================================${NC}"
        echo -e "${GREEN}✅ Despliegue completado!${NC}"
        echo -e "${BLUE}=========================================${NC}"
        echo ""
        echo -e "${YELLOW}La aplicación estará disponible en:${NC}"
        echo "  http://localhost:8080/logitrack/"
        echo ""
        echo -e "${YELLOW}Swagger UI:${NC}"
        echo "  http://localhost:8080/logitrack/swagger-ui.html"
        echo ""
        echo -e "${YELLOW}Logs de Tomcat:${NC}"
        echo "  tail -f $CATALINA_HOME/logs/catalina.out"
    else
        echo -e "${YELLOW}⚠ No se encontró startup.sh${NC}"
        echo -e "${YELLOW}Inicia Tomcat manualmente${NC}"
    fi
else
    echo -e "${YELLOW}6. WAR construido exitosamente${NC}"
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${GREEN}✅ Build completado!${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""
    echo -e "${YELLOW}Para desplegar en Tomcat:${NC}"
    echo ""
    echo -e "${YELLOW}Opción 1 - Despliegue automático:${NC}"
    echo "  ./build-y-desplegar.sh /ruta/a/tomcat"
    echo ""
    echo -e "${YELLOW}Opción 2 - Despliegue manual:${NC}"
    echo "  1. Detener Tomcat:"
    echo "     \$CATALINA_HOME/bin/shutdown.sh"
    echo ""
    echo "  2. Copiar WAR:"
    echo "     cp $WAR_FILE \$CATALINA_HOME/webapps/logitrack.war"
    echo ""
    echo "  3. Iniciar Tomcat:"
    echo "     \$CATALINA_HOME/bin/startup.sh"
    echo ""
    echo -e "${YELLOW}Opción 3 - Usar Tomcat Manager:${NC}"
    echo "  1. Acceder a: http://localhost:8080/manager/html"
    echo "  2. En 'WAR file to deploy', seleccionar: $WAR_FILE"
    echo "  3. Click en 'Deploy'"
fi

echo ""
echo -e "${YELLOW}IMPORTANTE:${NC}"
echo "  1. Asegúrate de que MySQL esté corriendo"
echo "  2. Verifica que la base de datos 'logitrack_db' exista"
echo "  3. Crea el usuario admin inicial (ver documentación)"
echo "  4. Configura las variables de entorno para producción"
echo ""
