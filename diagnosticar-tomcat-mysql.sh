#!/bin/bash

echo "========================================="
echo "  DIAGNÓSTICO TOMCAT - MYSQL"
echo "========================================="
echo ""

echo "1. Verificar con qué usuario corre Tomcat..."
echo "----------------------------------------"
ps aux | grep tomcat | grep -v grep | head -1

echo ""
echo "2. Verificar permisos del usuario MySQL 'campus2023'..."
echo "----------------------------------------"
sudo mysql -e "SELECT User, Host FROM mysql.user WHERE User = 'campus2023';"

echo ""
echo "3. Verificar grants del usuario..."
echo "----------------------------------------"
sudo mysql -e "SHOW GRANTS FOR 'campus2023'@'localhost';"

echo ""
echo "4. Últimos errores en logs de Tomcat..."
echo "----------------------------------------"
sudo tail -200 /opt/tomcat/logs/catalina.out | grep -i "error\|exception\|failed\|cannot" | tail -30

echo ""
echo "5. Buscar mensajes de Spring/Hibernate en logs..."
echo "----------------------------------------"
sudo tail -200 /opt/tomcat/logs/catalina.out | grep -i "datasource\|hibernate\|jpa\|mysql\|jdbc" | tail -20

echo ""
echo "6. Verificar si la aplicación arrancó correctamente..."
echo "----------------------------------------"
sudo tail -50 /opt/tomcat/logs/catalina.out | grep -i "started\|logitrack"

echo ""
echo "========================================="
echo "FIN DEL DIAGNÓSTICO"
echo "========================================="
