#!/bin/bash

echo "========================================="
echo "  DIAGNOSTICAR ERROR 403 EN REGISTRO"
echo "========================================="
echo ""
echo "Este script mostrará los últimos logs de Tomcat"
echo "para diagnosticar el error 403 al crear cuenta."
echo ""

sudo tail -100 /opt/tomcat/logs/catalina.out | grep -E -A 3 -B 3 "403|register|Auth|WARN|ERROR" --color=always

echo ""
echo "========================================="
echo "  ÚLTIMAS 30 LÍNEAS DEL LOG"
echo "========================================="
echo ""

sudo tail -30 /opt/tomcat/logs/catalina.out
