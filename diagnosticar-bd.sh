#!/bin/bash

echo "========================================="
echo "Diagnóstico de Base de Datos - LogiTrack"
echo "========================================="
echo ""

echo "Por favor ingresa la contraseña de campus2023 cuando se solicite."
echo ""

# Verificar si existe la base de datos
echo "1. Verificando si existe la base de datos..."
mysql -u campus2023 -p -e "SHOW DATABASES LIKE 'logitrack_db';"

echo ""
echo "2. Verificando tablas en logitrack_db..."
mysql -u campus2023 -p -e "USE logitrack_db; SHOW TABLES;"

echo ""
echo "3. Contando usuarios en la tabla..."
mysql -u campus2023 -p -e "USE logitrack_db; SELECT COUNT(*) as total_usuarios FROM usuario;"

echo ""
echo "4. Mostrando usuarios existentes..."
mysql -u campus2023 -p -e "USE logitrack_db; SELECT username, rol, nombre_completo FROM usuario;"

echo ""
echo "========================================="
echo "Diagnóstico completado"
echo "========================================="
