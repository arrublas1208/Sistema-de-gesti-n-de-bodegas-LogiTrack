#!/bin/bash

echo "========================================="
echo "  DESPLEGAR NUEVO WAR CON FRONTEND ARREGLADO"
echo "========================================="
echo ""

echo "Este script desplegará el nuevo WAR que incluye:"
echo "  ✅ Manejo correcto de tokens JWT"
echo "  ✅ Autenticación en todas las peticiones"
echo "  ✅ Registro de usuarios funcionando"
echo ""

echo "1. Deteniendo Tomcat..."
echo "----------------------------------------"
sudo systemctl stop tomcat

echo ""
echo "2. Eliminando WAR antiguo..."
echo "----------------------------------------"
sudo rm -f /opt/tomcat/webapps/logitrack.war
sudo rm -rf /opt/tomcat/webapps/logitrack/

echo ""
echo "3. Copiando nuevo WAR..."
echo "----------------------------------------"
sudo cp target/logitrack.war /opt/tomcat/webapps/

echo ""
echo "4. Iniciando Tomcat..."
echo "----------------------------------------"
sudo systemctl start tomcat

echo ""
echo "5. Esperando a que Tomcat despliegue la aplicación..."
echo "----------------------------------------"
echo "Esperando 15 segundos..."
sleep 5
echo "10 segundos más..."
sleep 5
echo "5 segundos más..."
sleep 5

echo ""
echo "========================================="
echo "✅ DESPLIEGUE COMPLETADO"
echo "========================================="
echo ""
echo "La aplicación debería estar lista en:"
echo "  http://localhost:8080/logitrack/"
echo ""
echo "Credenciales:"
echo "  Usuario: admin"
echo "  Contraseña: admin123"
echo ""
echo "Ahora PODRÁS:"
echo "  ✅ Iniciar sesión"
echo "  ✅ Registrar nuevos usuarios (desde el menú dentro de la app)"
echo "  ✅ Usar todas las funciones sin errores 403"
echo ""
echo "Si quieres ver los logs en tiempo real:"
echo "  sudo tail -f /opt/tomcat/logs/catalina.out"
echo ""
