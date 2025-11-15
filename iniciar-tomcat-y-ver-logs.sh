#!/bin/bash

echo "========================================="
echo "Iniciando Tomcat y Verificando Logs"
echo "========================================="
echo ""

# Verificar si el WAR existe
if [ ! -f /opt/tomcat/webapps/logitrack.war ]; then
    echo "❌ ERROR: No se encuentra /opt/tomcat/webapps/logitrack.war"
    echo ""
    echo "Primero debes copiar el WAR:"
    echo "  sudo cp target/logitrack.war /opt/tomcat/webapps/"
    echo "  sudo chown tomcat:tomcat /opt/tomcat/webapps/logitrack.war"
    exit 1
fi

echo "✓ WAR encontrado en /opt/tomcat/webapps/logitrack.war"
echo ""

# Limpiar despliegue anterior si existe
echo "Limpiando despliegue anterior..."
sudo rm -rf /opt/tomcat/webapps/logitrack
echo ""

# Iniciar Tomcat
echo "Iniciando Tomcat..."
sudo systemctl start tomcat

# Esperar un momento
echo "Esperando 3 segundos..."
sleep 3

# Verificar estado
echo ""
echo "Estado de Tomcat:"
sudo systemctl status tomcat --no-pager | head -10
echo ""

# Verificar que el puerto esté escuchando
echo "Verificando puerto 8080..."
if sudo lsof -i :8080 > /dev/null 2>&1; then
    echo "✓ Tomcat está escuchando en puerto 8080"
else
    echo "⚠ Puerto 8080 aún no está listo, espera unos segundos más"
fi

echo ""
echo "========================================="
echo "Mostrando logs en tiempo real..."
echo "========================================="
echo "Presiona Ctrl+C para salir"
echo ""
echo "Busca este mensaje de ÉXITO:"
echo "  'Started LogitrackApplication in X.XXX seconds'"
echo ""
sleep 2

# Seguir los logs
sudo tail -f /opt/tomcat/logs/catalina.out
