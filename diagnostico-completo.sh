#!/bin/bash

echo "========================================="
echo "  DIAGNÓSTICO COMPLETO DE BASE DE DATOS"
echo "========================================="
echo ""

mysql -u campus2023 -pcampus2023 << 'EOF'

-- Verificar que estamos en la BD correcta
SELECT DATABASE() as 'Base de datos actual';

SELECT '========================================' AS '';
SELECT 'PASO 1: Verificar tablas existentes' AS '';
SELECT '========================================' AS '';

SHOW TABLES FROM logitrack_db;

SELECT '' AS '';
SELECT '========================================' AS '';
SELECT 'PASO 2: Verificar estructura tabla usuario' AS '';
SELECT '========================================' AS '';

DESCRIBE logitrack_db.usuario;

SELECT '' AS '';
SELECT '========================================' AS '';
SELECT 'PASO 3: Verificar tabla empresa' AS '';
SELECT '========================================' AS '';

SELECT * FROM logitrack_db.empresa;

SELECT '' AS '';
SELECT '========================================' AS '';
SELECT 'PASO 4: Contar usuarios existentes' AS '';
SELECT '========================================' AS '';

SELECT COUNT(*) as 'Total usuarios' FROM logitrack_db.usuario;

SELECT '' AS '';
SELECT '========================================' AS '';
SELECT 'PASO 5: Mostrar TODOS los usuarios' AS '';
SELECT '========================================' AS '';

SELECT
  id,
  username,
  rol,
  nombre_completo,
  email,
  empresa_id,
  LEFT(password, 20) as 'password_inicio'
FROM logitrack_db.usuario;

SELECT '' AS '';
SELECT '========================================' AS '';
SELECT 'PASO 6: Buscar específicamente usuario admin' AS '';
SELECT '========================================' AS '';

SELECT * FROM logitrack_db.usuario WHERE username = 'admin';

EOF

echo ""
echo "========================================="
echo "FIN DEL DIAGNÓSTICO"
echo "========================================="
