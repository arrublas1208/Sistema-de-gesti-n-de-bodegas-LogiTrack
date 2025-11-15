#!/bin/bash

echo "========================================="
echo "Verificar Contraseña del Admin"
echo "========================================="
echo ""

echo "Mostrando el hash de la contraseña almacenada..."
echo ""

mysql -u campus2023 -p << 'EOF'
USE logitrack_db;

SELECT
  username,
  rol,
  LEFT(password, 20) as 'password_inicio',
  LENGTH(password) as 'longitud_hash'
FROM usuario
WHERE username = 'admin';

EOF

echo ""
echo "========================================="
echo "Hash correcto para 'Admin123!' debería:"
echo "========================================="
echo "Inicio: \$2a\$10\$N9qo8uLOickgx..."
echo "Longitud: 60 caracteres"
echo ""
