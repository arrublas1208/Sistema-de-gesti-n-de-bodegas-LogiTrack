#!/bin/bash

# Script de despliegue para LogiTrack en Tomcat
echo "Desplegando LogiTrack en Tomcat..."

# Detener aplicación anterior si existe
if [ -d "/opt/tomcat/webapps/logitrack" ]; then
    echo "Eliminando despliegue anterior..."
    sudo rm -rf /opt/tomcat/webapps/logitrack
    sudo rm -f /opt/tomcat/webapps/logitrack.war
fi

# Copiar nuevo WAR
echo "Copiando nuevo WAR..."
sudo cp /home/CAMPER/Desktop/Sistema-de-gesti-n-de-bodegas-LogiTrack/target/logitrack.war /opt/tomcat/webapps/

# Cambiar permisos
echo "Configurando permisos..."
sudo chown tomcat:tomcat /opt/tomcat/webapps/logitrack.war

echo "Despliegue completado. Tomcat desplegará automáticamente la aplicación."
echo "Puede verificar el despliegue en: http://localhost:8081/logitrack"
