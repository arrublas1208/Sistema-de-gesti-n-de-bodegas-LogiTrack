#!/bin/bash

echo "========================================="
echo "Verificar Usuario Admin en Base de Datos"
echo "========================================="
echo ""

echo "Verificando si el usuario 'admin' existe en logitrack_db..."
echo ""

mysql -u campus2023 -p << 'EOF'
USE logitrack_db;

-- Mostrar todos los usuarios
SELECT
  '========================' AS '';
SELECT 'USUARIOS EN LA BASE DE DATOS:' AS '';
SELECT '========================' AS '';

SELECT
  username as 'Usuario',
  rol as 'Rol',
  nombre_completo as 'Nombre',
  email as 'Email'
FROM usuario;

SELECT '' AS '';

-- Verificar específicamente el admin
SELECT '========================' AS '';
SELECT 'DETALLES DEL ADMIN:' AS '';
SELECT '========================' AS '';

SELECT
  username,
  rol,
  nombre_completo,
  email,
  LEFT(password, 30) as 'password_hash_inicio',
  LENGTH(password) as 'longitud_hash',
  empresa_id
FROM usuario
WHERE username = 'admin';

SELECT '' AS '';
SELECT 'Hash esperado para Admin123!:' AS '';
SELECT '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy' AS 'hash_correcto';
SELECT '' AS '';

EOF

echo ""
echo "========================================="
echo "Si el usuario admin NO aparece arriba:"
echo "========================================="
echo "  Ejecuta: mysql -u campus2023 -p logitrack_db < crear-admin.sql"
echo ""
echo "Si el usuario admin EXISTE pero el login falla:"
echo "========================================="
echo "  1. Verifica que el hash de password coincida"
echo "  2. Ejecuta: ./actualizar-password-admin.sh"
echo ""
