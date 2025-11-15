#!/bin/bash

echo "========================================="
echo "Verificar y Crear Usuario MySQL"
echo "========================================="
echo ""

echo "Este script verificará y creará el usuario 'campus2023' en MySQL"
echo "La aplicación necesita este usuario para conectarse a logitrack_db"
echo ""

read -p "¿Continuar? (s/n): " continuar
if [ "$continuar" != "s" ]; then
    echo "Cancelado."
    exit 0
fi

echo ""
echo "1. Verificando usuarios de MySQL existentes..."
echo "----------------------------------------"
echo "Por favor ingresa la contraseña de MySQL root cuando se solicite:"
echo ""

sudo mysql -e "SELECT User, Host FROM mysql.user WHERE User IN ('campus2023', 'logitrack_user', 'root');" 2>&1

if [ $? -ne 0 ]; then
    echo ""
    echo "⚠️  No se pudo conectar a MySQL. Verifica que MySQL esté corriendo."
    exit 1
fi

echo ""
echo "2. Creando/actualizando usuario 'campus2023'..."
echo "----------------------------------------"

sudo mysql << 'EOF'
-- Crear usuario campus2023 si no existe
CREATE USER IF NOT EXISTS 'campus2023'@'localhost'
  IDENTIFIED BY 'campus2023';

-- Otorgar todos los permisos en logitrack_db
GRANT ALL PRIVILEGES ON logitrack_db.* TO 'campus2023'@'localhost';

-- Aplicar cambios
FLUSH PRIVILEGES;

-- Verificar el usuario
SELECT
  'Usuario creado/actualizado:' AS Status,
  User,
  Host
FROM mysql.user
WHERE User = 'campus2023';

-- Verificar permisos
SHOW GRANTS FOR 'campus2023'@'localhost';
EOF

echo ""
echo "========================================="
echo "✅ Usuario 'campus2023' configurado!"
echo "========================================="
echo ""
echo "Ahora la aplicación debería poder conectarse a MySQL con:"
echo "  Usuario: campus2023"
echo "  Contraseña: campus2023"
echo "  Base de datos: logitrack_db"
echo ""
echo "Siguiente paso: Verificar que el usuario admin existe en la BD"
echo "  Ejecuta: ./verificar-usuario-admin.sh"
echo ""
