#!/bin/bash

echo "========================================="
echo "Actualizar Contraseña del Admin"
echo "========================================="
echo ""
echo "Este script actualizará la contraseña del admin a: Admin123!"
echo ""

mysql -u campus2023 -p << 'EOF'
USE logitrack_db;

-- Actualizar la contraseña del admin
UPDATE usuario
SET password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
WHERE username = 'admin';

-- Verificar el cambio
SELECT
  username,
  rol,
  LEFT(password, 30) as 'password_actualizado',
  'Admin123!' as 'nueva_contraseña'
FROM usuario
WHERE username = 'admin';

EOF

echo ""
echo "========================================="
echo "✅ Contraseña actualizada!"
echo "========================================="
echo ""
echo "Ahora prueba hacer login con:"
echo "  Usuario: admin"
echo "  Contraseña: Admin123!"
echo ""
echo "En: http://localhost:8080/logitrack/"
echo ""
