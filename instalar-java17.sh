#!/bin/bash

# Script para instalar Java 17 en Ubuntu/Debian
# Ejecutar con: sudo ./instalar-java17.sh

set -e

echo "========================================="
echo "Instalación de Java 17 para LogiTrack"
echo "========================================="
echo ""

# Verificar si se ejecuta con sudo
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Este script debe ejecutarse con sudo"
    echo "Uso: sudo ./instalar-java17.sh"
    exit 1
fi

echo "1. Actualizando repositorios..."
apt update

echo ""
echo "2. Instalando OpenJDK 17..."
apt install -y openjdk-17-jdk openjdk-17-jre

echo ""
echo "3. Configurando Java 17 como versión por defecto..."
update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac

echo ""
echo "4. Verificando instalación..."
java -version
javac -version

echo ""
echo "5. Configurando JAVA_HOME..."
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" >> /etc/environment
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/environment

echo ""
echo "========================================="
echo "✅ Java 17 instalado correctamente!"
echo "========================================="
echo ""
echo "Versión instalada:"
java -version
echo ""
echo "IMPORTANTE: Cierra y vuelve a abrir tu terminal para que los cambios tengan efecto."
echo ""
