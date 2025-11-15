#!/bin/bash

echo "========================================="
echo "  CAPTURAR LOGS DE TOMCAT"
echo "========================================="
echo ""
echo "Este script mostrará los últimos 100 logs de Tomcat"
echo "Busca específicamente errores de conexión a BD"
echo ""

sudo tail -100 /opt/tomcat/logs/catalina.out | grep -E -i "error|exception|datasource|jdbc|mysql|connection|failed|cannot|password|authentication" --color=always

echo ""
echo "========================================="
echo "  LOGS COMPLETOS (últimas 50 líneas)"
echo "========================================="
echo ""

sudo tail -50 /opt/tomcat/logs/catalina.out
