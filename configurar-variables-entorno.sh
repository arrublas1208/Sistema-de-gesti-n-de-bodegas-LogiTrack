#!/bin/bash

# Script para configurar variables de entorno para LogiTrack
# Este script crea el archivo setenv.sh para Tomcat

set -e

echo "========================================="
echo "Configuración de Variables de Entorno"
echo "========================================="
echo ""

# Solicitar CATALINA_HOME si no está configurado
if [ -z "$1" ]; then
    echo "Uso: $0 <CATALINA_HOME>"
    echo "Ejemplo: $0 /opt/tomcat"
    echo ""
    echo "CATALINA_HOME es el directorio donde está instalado Tomcat"
    exit 1
fi

CATALINA_HOME="$1"

if [ ! -d "$CATALINA_HOME" ]; then
    echo "ERROR: El directorio no existe: $CATALINA_HOME"
    exit 1
fi

if [ ! -d "$CATALINA_HOME/bin" ]; then
    echo "ERROR: No se encontró el directorio bin en: $CATALINA_HOME"
    exit 1
fi

echo "CATALINA_HOME: $CATALINA_HOME"
echo ""

# Solicitar configuración de base de datos
echo "Configuración de Base de Datos:"
echo "================================"
read -p "Host de MySQL (default: localhost): " DB_HOST
DB_HOST=${DB_HOST:-localhost}

read -p "Puerto de MySQL (default: 3306): " DB_PORT
DB_PORT=${DB_PORT:-3306}

read -p "Nombre de la base de datos (default: logitrack_db): " DB_NAME
DB_NAME=${DB_NAME:-logitrack_db}

read -p "Usuario de MySQL (default: root): " DB_USER
DB_USER=${DB_USER:-root}

read -sp "Contraseña de MySQL: " DB_PASS
echo ""

# Solicitar configuración de JWT
echo ""
echo "Configuración de JWT:"
echo "====================="
echo "Para producción, genera un secreto seguro con:"
echo "  openssl rand -base64 64"
echo ""
read -p "JWT Secret (Enter para usar uno generado): " JWT_SECRET

if [ -z "$JWT_SECRET" ]; then
    # Generar un secreto aleatorio
    JWT_SECRET=$(openssl rand -base64 64 | tr -d '\n' 2>/dev/null || echo "CHANGE-THIS-SECRET-IN-PRODUCTION-USE-AT-LEAST-256-BITS-RANDOM-STRING-HERE!!")
    echo "Usando secreto generado automáticamente"
fi

read -p "JWT Validity (ms) (default: 3600000 = 1 hora): " JWT_VALIDITY
JWT_VALIDITY=${JWT_VALIDITY:-3600000}

# Solicitar configuración de CORS
echo ""
echo "Configuración de CORS:"
echo "======================"
echo "Ejemplo: http://localhost:5173,http://localhost:3000"
read -p "Orígenes permitidos (default: http://localhost:8080): " CORS_ORIGINS
CORS_ORIGINS=${CORS_ORIGINS:-http://localhost:8080}

# Crear archivo setenv.sh
SETENV_FILE="$CATALINA_HOME/bin/setenv.sh"

echo ""
echo "Creando archivo: $SETENV_FILE"

cat > "$SETENV_FILE" << EOF
#!/bin/bash

# Variables de entorno para LogiTrack
# Generado automáticamente el $(date)

# Configuración de Base de Datos
export DB_URL="jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&createDatabaseIfNotExist=false"
export DB_USERNAME="${DB_USER}"
export DB_PASSWORD="${DB_PASS}"

# Configuración de JWT
export JWT_SECRET="${JWT_SECRET}"
export JWT_VALIDITY_MS=${JWT_VALIDITY}

# Configuración de CORS
export CORS_ALLOWED_ORIGINS="${CORS_ORIGINS}"

# Configuración de Java (opcional)
# export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
# export PATH=\$JAVA_HOME/bin:\$PATH

# Configuración de memoria JVM (opcional - ajustar según necesidades)
export CATALINA_OPTS="\$CATALINA_OPTS -Xms512m -Xmx1024m"
export CATALINA_OPTS="\$CATALINA_OPTS -XX:+UseG1GC"
export CATALINA_OPTS="\$CATALINA_OPTS -Djava.security.egd=file:/dev/./urandom"

# Activar modo de producción
export CATALINA_OPTS="\$CATALINA_OPTS -Dspring.profiles.active=prod"

echo "Variables de entorno de LogiTrack cargadas"
EOF

chmod +x "$SETENV_FILE"

echo ""
echo "========================================="
echo "✅ Configuración completada!"
echo "========================================="
echo ""
echo "El archivo setenv.sh ha sido creado en:"
echo "  $SETENV_FILE"
echo ""
echo "Las variables se cargarán automáticamente cuando inicies Tomcat."
echo ""
echo "IMPORTANTE:"
echo "  1. El archivo contiene contraseñas sensibles"
echo "  2. Asegúrate de que solo el usuario de Tomcat pueda leerlo:"
echo "     chmod 600 $SETENV_FILE"
echo "  3. NO incluyas este archivo en el control de versiones"
echo ""
echo "Para verificar que las variables se carguen correctamente:"
echo "  1. Inicia Tomcat: $CATALINA_HOME/bin/startup.sh"
echo "  2. Revisa los logs: tail -f $CATALINA_HOME/logs/catalina.out"
echo ""
