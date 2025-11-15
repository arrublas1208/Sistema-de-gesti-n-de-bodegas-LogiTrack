#!/bin/bash

echo "========================================="
echo "  DESPLEGAR WAR - REGISTRO ARREGLADO"
echo "========================================="
echo ""
echo "Cambios aplicados:"
echo "  ✅ Registro de admin ahora funciona desde login"
echo "  ✅ No dará error 403 al crear cuenta"
echo ""
echo "⚠️  ADVERTENCIA DE SEGURIDAD:"
echo "  Ahora CUALQUIERA puede crear admins desde /logitrack/"
echo "  Esto es SOLO para desarrollo/demo"
echo "  En producción, desactiva esta funcionalidad"
echo ""

read -p "¿Continuar con el despliegue? (s/n): " respuesta
if [ "$respuesta" != "s" ]; then
    echo "Despliegue cancelado"
    exit 0
fi

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
echo "5. Esperando a que Tomcat despliegue..."
echo "----------------------------------------"
for i in {15..1}; do
    echo -ne "Esperando $i segundos...\r"
    sleep 1
done
echo ""

echo ""
echo "========================================="
echo "✅ DESPLIEGUE COMPLETADO"
echo "========================================="
echo ""
echo "URL: http://localhost:8080/logitrack/"
echo ""
echo "AHORA PUEDES:"
echo "  1. Hacer clic en 'Crear cuenta (Admin)' desde el login"
echo "  2. Llenar el formulario de registro"
echo "  3. Crear nuevos usuarios admin SIN error 403"
echo ""
echo "O también puedes:"
echo "  1. Iniciar sesión con: admin / admin123"
echo "  2. Ir al menú 'Usuarios' dentro de la app"
echo "  3. Crear empleados desde ahí"
echo ""
echo "Si quieres ver los logs:"
echo "  sudo tail -f /opt/tomcat/logs/catalina.out"
echo ""
