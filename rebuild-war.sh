#!/bin/bash

echo "========================================="
echo "Reconstruyendo WAR de LogiTrack"
echo "========================================="
echo ""

# Limpiar target con permisos correctos
echo "1. Limpiando directorio target..."
sudo rm -rf target/
echo "✓ Limpieza completada"
echo ""

# Construir WAR
echo "2. Construyendo WAR..."
./mvnw package -DskipTests

# Verificar que se construyó correctamente
if [ -f target/logitrack.war ]; then
    echo ""
    echo "========================================="
    echo "✅ WAR construido exitosamente!"
    echo "========================================="
    echo ""
    echo "Ubicación: target/logitrack.war"
    ls -lh target/logitrack.war
    echo ""
    echo "Para desplegar, ejecuta:"
    echo "  sudo systemctl stop tomcat"
    echo "  sudo rm -rf /opt/tomcat/webapps/logitrack*"
    echo "  sudo cp target/logitrack.war /opt/tomcat/webapps/"
    echo "  sudo chown tomcat:tomcat /opt/tomcat/webapps/logitrack.war"
    echo "  sudo systemctl start tomcat"
    echo "  sudo tail -f /opt/tomcat/logs/catalina.out"
else
    echo ""
    echo "❌ Error: No se pudo construir el WAR"
    exit 1
fi
