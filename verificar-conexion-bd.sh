#!/bin/bash

echo "========================================="
echo "Verificar Conexión a Base de Datos"
echo "========================================="
echo ""

echo "1. Verificando configuración de application.properties..."
echo "----------------------------------------"
grep "datasource.url\|datasource.username\|datasource.password" src/main/resources/application.properties | head -5
echo ""

echo "2. Verificando si hay variables de entorno en Tomcat..."
echo "----------------------------------------"
if [ -f /opt/tomcat/bin/setenv.sh ]; then
    echo "✓ Archivo setenv.sh existe"
    sudo cat /opt/tomcat/bin/setenv.sh | grep -v "PASSWORD\|SECRET" | grep "DB_"
else
    echo "✗ No existe /opt/tomcat/bin/setenv.sh"
    echo "  La aplicación está usando los valores por defecto de application.properties"
fi
echo ""

echo "3. Configuración por defecto (si no hay variables de entorno):"
echo "----------------------------------------"
echo "Base de datos: logitrack_db"
echo "Usuario: campus2023"
echo "Contraseña: campus2023"
echo ""

echo "4. Verificando qué usuarios hay en logitrack_db..."
echo "----------------------------------------"
mysql -u campus2023 -p -e "USE logitrack_db; SELECT username, rol, nombre_completo FROM usuario;"
echo ""

echo "5. Intentando login desde la aplicación (revisar logs)..."
echo "----------------------------------------"
echo "Ejecuta este comando en otra terminal para ver los logs en tiempo real:"
echo "  sudo tail -f /opt/tomcat/logs/catalina.out"
echo ""
echo "Luego intenta hacer login desde el navegador y observa:"
echo "  - ¿Se ejecuta la consulta SQL?"
echo "  - ¿Qué username busca?"
echo "  - ¿Encuentra el usuario?"
echo ""
