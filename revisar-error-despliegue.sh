#!/bin/bash

# Script para revisar los errores de despliegue de LogiTrack en Tomcat

echo "========================================="
echo "Diagnóstico de Error de Despliegue"
echo "========================================="
echo ""

# 1. Ver últimas 300 líneas del log de Tomcat
echo "1. LOGS DE TOMCAT (catalina.out):"
echo "========================================="
sudo tail -300 /opt/tomcat/logs/catalina.out | grep -A 30 -B 10 -i "logitrack\|error\|exception\|failed"
echo ""

# 2. Ver logs específicos de logitrack si existen
echo ""
echo "2. LOGS ESPECÍFICOS DE LOGITRACK:"
echo "========================================="
if [ -f /opt/tomcat/logs/logitrack.log ]; then
    sudo tail -100 /opt/tomcat/logs/logitrack.log
else
    echo "No se encontró logitrack.log"
fi
echo ""

# 3. Ver logs del día de hoy
echo ""
echo "3. CATALINA LOG DEL DÍA:"
echo "========================================="
TODAY=$(date +%Y-%m-%d)
if [ -f /opt/tomcat/logs/catalina.$TODAY.log ]; then
    sudo tail -100 /opt/tomcat/logs/catalina.$TODAY.log | grep -A 20 -i "logitrack\|error"
fi
echo ""

# 4. Verificar estado de la aplicación
echo ""
echo "4. ESTADO DE LA APLICACIÓN:"
echo "========================================="
echo "Directorio webapps:"
ls -la /opt/tomcat/webapps/ | grep logitrack
echo ""

# 5. Verificar si el WAR se desempaquetó
if [ -d /opt/tomcat/webapps/logitrack ]; then
    echo "✓ El WAR se desempaquetó correctamente"
    echo "Archivos principales:"
    ls -la /opt/tomcat/webapps/logitrack/ | head -10
else
    echo "✗ El WAR NO se desempaquetó"
fi
echo ""

# 6. Verificar MySQL
echo ""
echo "5. ESTADO DE MYSQL:"
echo "========================================="
if systemctl is-active --quiet mysql || systemctl is-active --quiet mysqld; then
    echo "✓ MySQL está corriendo"
    mysql --version 2>/dev/null || echo "Cliente MySQL no encontrado"
else
    echo "✗ MySQL NO está corriendo"
    echo "Iniciar con: sudo systemctl start mysql"
fi
echo ""

# 7. Verificar Java
echo ""
echo "6. VERSIÓN DE JAVA:"
echo "========================================="
java -version 2>&1 | head -3
echo ""

# 8. Verificar variables de entorno de Tomcat
echo ""
echo "7. VARIABLES DE ENTORNO (setenv.sh):"
echo "========================================="
if [ -f /opt/tomcat/bin/setenv.sh ]; then
    echo "✓ setenv.sh existe"
    echo "Contenido (sin contraseñas):"
    sudo cat /opt/tomcat/bin/setenv.sh | grep -v "PASSWORD" | grep -v "SECRET"
else
    echo "✗ setenv.sh NO existe"
    echo "Las variables de entorno NO están configuradas!"
fi
echo ""

echo ""
echo "========================================="
echo "FIN DEL DIAGNÓSTICO"
echo "========================================="
echo ""
echo "PASOS SIGUIENTES:"
echo "1. Revisa los errores arriba (busca 'Exception' o 'Error')"
echo "2. Los errores más comunes son:"
echo "   - Variables de entorno no configuradas"
echo "   - MySQL no está corriendo"
echo "   - Error de conexión a base de datos"
echo "   - El WAR se compiló con Java incorrecto"
echo ""
