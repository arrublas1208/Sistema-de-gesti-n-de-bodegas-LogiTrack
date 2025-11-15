#!/bin/bash

echo "========================================="
echo "  PROBAR CONEXIÓN A MYSQL"
echo "========================================="
echo ""
echo "Probando si el usuario 'campus2023' puede conectarse a 'logitrack_db'..."
echo ""

# Probar conexión
mysql -u campus2023 -pcampus2023 -e "SELECT 'Conexión exitosa' AS Status, DATABASE() AS 'Base de datos actual'; USE logitrack_db; SELECT COUNT(*) AS 'Total usuarios en logitrack_db' FROM usuario;" 2>&1

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "✅ CONEXIÓN EXITOSA"
    echo "========================================="
    echo ""
    echo "El usuario 'campus2023' SÍ puede conectarse a MySQL"
    echo "El problema debe estar en la configuración de Tomcat"
    echo ""
    echo "Siguiente paso: Revisar logs de Tomcat"
    echo "  Ejecuta: sudo tail -100 /opt/tomcat/logs/catalina.out"
    echo ""
else
    echo ""
    echo "========================================="
    echo "❌ CONEXIÓN FALLIDA"
    echo "========================================="
    echo ""
    echo "El usuario 'campus2023' NO puede conectarse a MySQL"
    echo ""
    echo "SOLUCIÓN:"
    echo "  1. Ejecuta: sudo mysql"
    echo "  2. Luego copia y pega estos comandos:"
    echo ""
    echo "     CREATE USER IF NOT EXISTS 'campus2023'@'localhost' IDENTIFIED BY 'campus2023';"
    echo "     GRANT ALL PRIVILEGES ON logitrack_db.* TO 'campus2023'@'localhost';"
    echo "     FLUSH PRIVILEGES;"
    echo "     SELECT User, Host FROM mysql.user WHERE User = 'campus2023';"
    echo "     exit"
    echo ""
    echo "  3. Vuelve a ejecutar este script: ./probar-conexion-mysql.sh"
    echo ""
fi
