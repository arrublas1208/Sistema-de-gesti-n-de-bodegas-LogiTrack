#!/bin/bash

echo "========================================="
echo "  RECOMPILAR Y DESPLEGAR FRONTEND"
echo "========================================="
echo ""

cd frontend || exit 1

echo "1. Instalando dependencias de Node.js..."
echo "----------------------------------------"
npm install

if [ $? -ne 0 ]; then
    echo "❌ Error instalando dependencias"
    exit 1
fi

echo ""
echo "2. Compilando frontend (producción)..."
echo "----------------------------------------"
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Error compilando frontend"
    exit 1
fi

echo ""
echo "3. Copiando archivos al directorio static..."
echo "----------------------------------------"
cd ..
rm -rf src/main/resources/static/*
cp -r frontend/dist/* src/main/resources/static/

echo ""
echo "4. Recompilando WAR..."
echo "----------------------------------------"
./mvnw clean package -DskipTests

if [ $? -ne 0 ]; then
    echo "❌ Error compilando WAR"
    exit 1
fi

echo ""
echo "========================================="
echo "✅ COMPILACIÓN EXITOSA"
echo "========================================="
echo ""
echo "El nuevo WAR está en: target/logitrack.war"
echo ""
echo "SIGUIENTE PASO:"
echo "  1. Detén Tomcat: sudo systemctl stop tomcat"
echo "  2. Copia el WAR: sudo cp target/logitrack.war /opt/tomcat/webapps/"
echo "  3. Inicia Tomcat: sudo systemctl start tomcat"
echo "  4. Espera 10 segundos y abre: http://localhost:8080/logitrack/"
echo ""
