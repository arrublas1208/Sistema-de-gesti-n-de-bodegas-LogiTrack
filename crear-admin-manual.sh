#!/bin/bash

echo "========================================="
echo "Crear Usuario Admin - LogiTrack"
echo "========================================="
echo ""
echo "Este script creará el usuario admin en la base de datos."
echo "Por favor ingresa la contraseña de campus2023 cuando se solicite."
echo ""

# Crear el usuario admin
mysql -u campus2023 -p << 'EOF'
USE logitrack_db;

-- Verificar si ya existe la empresa
SELECT 'Verificando empresa...' AS paso;
INSERT IGNORE INTO empresa (id, nombre) VALUES (1, 'Mi Empresa');

-- Eliminar admin si existe (para recrearlo)
DELETE FROM usuario WHERE username = 'admin';

-- Crear usuario admin
-- Contraseña: Admin123!
INSERT INTO usuario (
  username,
  password,
  rol,
  nombre_completo,
  email,
  cedula,
  empresa_id
) VALUES (
  'admin',
  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
  'ADMIN',
  'Administrador Principal',
  'admin@logitrack.com',
  '1234567890',
  1
);

-- Mostrar resultado
SELECT 'Usuario admin creado exitosamente!' AS resultado;
SELECT username, rol, nombre_completo, email FROM usuario WHERE username = 'admin';

EOF

echo ""
echo "========================================="
echo "✅ Usuario admin creado!"
echo "========================================="
echo ""
echo "Credenciales:"
echo "  Usuario: admin"
echo "  Contraseña: Admin123!"
echo ""
echo "Ahora prueba hacer login en:"
echo "  http://localhost:8080/logitrack/"
echo ""
