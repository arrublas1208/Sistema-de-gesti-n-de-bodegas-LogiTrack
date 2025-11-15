#!/bin/bash

echo "========================================="
echo "   SOLUCIONAR PROBLEMA DE LOGIN"
echo "========================================="
echo ""
echo "Este script solucionará el problema de login en 3 pasos:"
echo ""
echo "  PASO 1: Crear usuario MySQL 'campus2023'"
echo "  PASO 2: Verificar usuario 'admin' en la BD"
echo "  PASO 3: Actualizar contraseña del admin"
echo ""
echo "========================================="
echo ""

# PASO 1: Crear usuario MySQL
echo "PASO 1/3: Creando usuario MySQL 'campus2023'..."
echo "========================================="
echo ""
echo "El problema detectado:"
echo "  - La aplicación busca el usuario MySQL 'campus2023'"
echo "  - Pero solo existe 'logitrack_user'"
echo "  - Vamos a crear 'campus2023' con los permisos correctos"
echo ""

sudo mysql << 'EOF'
-- Crear usuario campus2023 si no existe
CREATE USER IF NOT EXISTS 'campus2023'@'localhost'
  IDENTIFIED BY 'campus2023';

-- Otorgar todos los permisos en logitrack_db
GRANT ALL PRIVILEGES ON logitrack_db.* TO 'campus2023'@'localhost';

-- Aplicar cambios
FLUSH PRIVILEGES;

-- Verificar
SELECT '✅ Usuario MySQL creado:' AS Status, User, Host
FROM mysql.user
WHERE User = 'campus2023';
EOF

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Error al crear usuario MySQL. Verifica que MySQL esté corriendo."
    echo "   Intenta ejecutar: sudo systemctl status mysql"
    exit 1
fi

echo ""
echo "✅ Usuario MySQL 'campus2023' creado exitosamente!"
echo ""

# PASO 2: Verificar usuario admin en BD
echo "========================================="
echo "PASO 2/3: Verificando usuario 'admin' en logitrack_db..."
echo "========================================="
echo ""

echo "Ingresa la contraseña del usuario MySQL 'campus2023': campus2023"
echo ""

ADMIN_EXISTS=$(mysql -u campus2023 -pcampus2023 -s -N -e "USE logitrack_db; SELECT COUNT(*) FROM usuario WHERE username = 'admin';" 2>/dev/null)

if [ "$ADMIN_EXISTS" = "1" ]; then
    echo "✅ Usuario admin EXISTE en la base de datos"
    echo ""

    # Mostrar detalles del admin
    mysql -u campus2023 -pcampus2023 << 'EOF'
USE logitrack_db;

SELECT
  username as 'Usuario',
  rol as 'Rol',
  nombre_completo as 'Nombre',
  email as 'Email',
  LEFT(password, 30) as 'Hash Password (primeros 30 chars)'
FROM usuario
WHERE username = 'admin';
EOF

else
    echo "❌ Usuario admin NO EXISTE. Creándolo ahora..."
    echo ""

    mysql -u campus2023 -pcampus2023 logitrack_db < crear-admin.sql

    if [ $? -eq 0 ]; then
        echo "✅ Usuario admin creado exitosamente!"
    else
        echo "❌ Error al crear usuario admin."
        exit 1
    fi
fi

echo ""

# PASO 3: Actualizar contraseña
echo "========================================="
echo "PASO 3/3: Actualizando contraseña del admin..."
echo "========================================="
echo ""
echo "Estableciendo contraseña a: Admin123!"
echo ""

mysql -u campus2023 -pcampus2023 << 'EOF'
USE logitrack_db;

-- Actualizar la contraseña del admin
UPDATE usuario
SET password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
WHERE username = 'admin';

-- Verificar el cambio
SELECT
  '✅ Contraseña actualizada:' AS Status,
  username,
  rol,
  LEFT(password, 30) as 'password_hash',
  'Admin123!' as 'nueva_contraseña'
FROM usuario
WHERE username = 'admin';
EOF

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Error al actualizar contraseña."
    exit 1
fi

echo ""
echo "========================================="
echo "   ✅ ¡TODO LISTO!"
echo "========================================="
echo ""
echo "La configuración es ahora:"
echo ""
echo "  📊 Base de datos: logitrack_db"
echo "  👤 Usuario MySQL: campus2023"
echo "  🔑 Password MySQL: campus2023"
echo ""
echo "  🔐 Usuario admin app: admin"
echo "  🔑 Password admin app: Admin123!"
echo ""
echo "========================================="
echo "   PRUEBA EL LOGIN AHORA"
echo "========================================="
echo ""
echo "1. Abre: http://localhost:8080/logitrack/"
echo ""
echo "2. Ingresa:"
echo "   Usuario: admin"
echo "   Contraseña: Admin123!"
echo ""
echo "3. Si aún falla, reinicia Tomcat:"
echo "   sudo systemctl restart tomcat"
echo ""
echo "4. Monitorea los logs mientras pruebas el login:"
echo "   sudo tail -f /opt/tomcat/logs/catalina.out"
echo ""
