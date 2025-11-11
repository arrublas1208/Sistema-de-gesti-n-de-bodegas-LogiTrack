#!/usr/bin/env bash
set -euo pipefail

# LogiTrack - Arranque en Linux con configuración por variables o flags
#
# Uso básico:
#   ./run-linux.sh                       # arranca con defaults
#   ./run-linux.sh -p 8082               # cambia el puerto
#   ./run-linux.sh --db-host 127.0.0.1 --db-name logitrack_db
#   PORT=8083 ./run-linux.sh             # usando variable de entorno
#   ./run-linux.sh --jar                 # ejecuta el JAR en lugar de mvn
#
# Variables de entorno soportadas:
#   PORT (default 8081)
#   DB_HOST (default localhost)
#   DB_PORT (default 3306)
#   DB_NAME (default logitrack_db)
#   SPRING_DATASOURCE_USERNAME (default root)
#   SPRING_DATASOURCE_PASSWORD (default root)
#   RUN_MODE (mvn|jar, default mvn)

PORT="${PORT:-8081}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-logitrack_db}"
DB_USER="${SPRING_DATASOURCE_USERNAME:-root}"
DB_PASS="${SPRING_DATASOURCE_PASSWORD:-root}"
RUN_MODE="${RUN_MODE:-mvn}"  # mvn o jar

print_usage() {
  cat <<EOF
Uso: $0 [opciones]

Opciones:
  -p, --port PORT         Puerto HTTP (default: ${PORT})
      --db-host HOST      Host de MySQL (default: ${DB_HOST})
      --db-port PORT      Puerto de MySQL (default: ${DB_PORT})
      --db-name NAME      Nombre de base (default: ${DB_NAME})
  -u, --user USER         Usuario MySQL (default: ${DB_USER})
  -w, --pass PASS         Password MySQL (default: oculto)
      --jar               Ejecutar usando el JAR empaquetado
  -h, --help              Mostrar esta ayuda

También puedes usar variables de entorno:
  PORT, DB_HOST, DB_PORT, DB_NAME, SPRING_DATASOURCE_USERNAME, SPRING_DATASOURCE_PASSWORD, RUN_MODE

Ejemplos:
  PORT=8082 ./run-linux.sh
  ./run-linux.sh -p 8083 --db-host 127.0.0.1 --db-name logitrack_db
  ./run-linux.sh --jar -p 8082
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--port)
      PORT="$2"; shift 2;;
    --db-host)
      DB_HOST="$2"; shift 2;;
    --db-port)
      DB_PORT="$2"; shift 2;;
    --db-name)
      DB_NAME="$2"; shift 2;;
    -u|--user)
      DB_USER="$2"; shift 2;;
    -w|--pass)
      DB_PASS="$2"; shift 2;;
    --jar)
      RUN_MODE="jar"; shift;;
    -h|--help)
      print_usage; exit 0;;
    *)
      echo "Opción desconocida: $1" >&2
      print_usage; exit 1;;
  esac
done

# Exportar variables para Spring Boot
export PORT
export SPRING_DATASOURCE_URL="jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&createDatabaseIfNotExist=true"
export SPRING_DATASOURCE_USERNAME="${DB_USER}"
export SPRING_DATASOURCE_PASSWORD="${DB_PASS}"

echo "========================================="
echo "LogiTrack - Inicio"
echo "Puerto           : ${PORT}"
echo "DB URL           : ${SPRING_DATASOURCE_URL}"
echo "DB Usuario       : ${SPRING_DATASOURCE_USERNAME}"
echo "Modo de ejecución: ${RUN_MODE}"
echo "========================================="

# Ir al directorio del script para que rutas relativas funcionen
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

if [[ "$RUN_MODE" == "jar" ]]; then
  JAR="target/logitrack-0.0.1-SNAPSHOT.jar"
  if [[ ! -f "$JAR" ]]; then
    echo "Empaquetando JAR (sin tests)..."
    mvn -DskipTests package
  fi
  echo "Ejecutando JAR..."
  exec java -jar "$JAR"
else
  # Ejecutar con Maven (requiere mvn instalado)
  echo "Ejecutando con Maven..."
  exec mvn spring-boot:run
fi