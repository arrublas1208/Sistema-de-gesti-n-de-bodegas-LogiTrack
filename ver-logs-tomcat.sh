#!/bin/bash

echo "========================================="
echo "LOGS DE TOMCAT - LogiTrack"
echo "========================================="
echo ""

echo "Buscando errores en catalina.out..."
echo "========================================="
echo ""

# Buscar específicamente errores relacionados con logitrack
sudo tail -500 /opt/tomcat/logs/catalina.out | grep -A 50 "logitrack" | tail -100

echo ""
echo "========================================="
echo "Buscando excepciones y errores generales..."
echo "========================================="
echo ""

# Buscar las últimas excepciones
sudo tail -500 /opt/tomcat/logs/catalina.out | grep -B 5 -A 30 -E "Exception|Error|SEVERE|FATAL" | tail -100

echo ""
echo "========================================="
echo "Estado del WAR desplegado:"
echo "========================================="
echo ""

ls -la /opt/tomcat/webapps/ | grep logitrack

echo ""
if [ -d /opt/tomcat/webapps/logitrack ]; then
    echo "✓ WAR desempaquetado en: /opt/tomcat/webapps/logitrack/"
    echo "Archivos principales:"
    ls -la /opt/tomcat/webapps/logitrack/ 2>/dev/null | head -10
else
    echo "✗ WAR NO se ha desempaquetado"
fi

echo ""
echo "========================================="
echo "Variables de entorno (setenv.sh):"
echo "========================================="
echo ""

if [ -f /opt/tomcat/bin/setenv.sh ]; then
    echo "✓ setenv.sh EXISTE"
    echo "Contenido (ocultando contraseñas):"
    sudo cat /opt/tomcat/bin/setenv.sh | sed 's/PASSWORD=.*/PASSWORD=***OCULTO***/g' | sed 's/SECRET=.*/SECRET=***OCULTO***/g'
else
    echo "✗ setenv.sh NO EXISTE - ¡ESTE ES PROBABLEMENTE EL PROBLEMA!"
    echo ""
    echo "Solución: Ejecuta ./configurar-variables-entorno.sh /opt/tomcat"
fi

echo ""
echo "========================================="
echo "FIN - Copia el error de arriba"
echo "========================================="
