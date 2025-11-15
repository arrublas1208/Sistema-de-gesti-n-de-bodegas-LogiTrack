# Instrucciones para Reconstruir y Redesplegar

## ✅ Corrección Aplicada

He corregido el problema en `src/main/resources/application.properties`:

```properties
spring.main.web-application-type=servlet
```

Esta línea **desactiva el servidor embebido de Spring Boot**, lo que soluciona el error:
```
Failed to register 'filter errorPageFilterRegistration' on the servlet context
```

---

## 🔨 Paso 1: Reconstruir el WAR

Ejecuta estos comandos en tu terminal:

```bash
# Limpiar el directorio target (requiere sudo por permisos)
sudo rm -rf target/

# Reconstruir el WAR
./mvnw package -DskipTests
```

**Espera a que termine** (puede tomar 1-2 minutos). Deberías ver:

```
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
```

Verifica que el WAR se creó:

```bash
ls -lh target/logitrack.war
```

Debería mostrar un archivo de ~60-70 MB.

---

## 🚀 Paso 2: Redesplegar en Tomcat

Una vez que el WAR esté construido, ejecuta:

```bash
# Detener Tomcat
sudo systemctl stop tomcat

# Eliminar despliegue anterior
sudo rm -rf /opt/tomcat/webapps/logitrack*

# Copiar nuevo WAR
sudo cp target/logitrack.war /opt/tomcat/webapps/

# Dar permisos correctos
sudo chown tomcat:tomcat /opt/tomcat/webapps/logitrack.war

# Iniciar Tomcat
sudo systemctl start tomcat
```

---

## 👀 Paso 3: Verificar el Despliegue

Ver los logs en tiempo real:

```bash
sudo tail -f /opt/tomcat/logs/catalina.out
```

**Busca este mensaje (indica ÉXITO):**

```
Started LogitrackApplication in X.XXX seconds
```

**Si ves esto, significa que funcionó!** ✅

Presiona `Ctrl+C` para salir de los logs.

---

## 🧪 Paso 4: Probar la Aplicación

### Opción A: Desde el Navegador

Abre: http://localhost:8080/logitrack/

### Opción B: Probar API con curl

```bash
# Crear base de datos y usuario (si aún no lo hiciste)
mysql -u root -p < crear-bd.sql

# Crear usuario admin (si aún no lo hiciste)
mysql -u logitrack_user -p logitrack_db < crear-admin.sql

# Probar login
curl -X POST http://localhost:8080/logitrack/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "Admin123!"
  }'
```

**Respuesta esperada:**

```json
{
  "token": "eyJhbGc...",
  "type": "Bearer",
  "username": "admin",
  "rol": "ADMIN"
}
```

### Opción C: Swagger UI

Abre: http://localhost:8080/logitrack/swagger-ui.html

---

## ⚠️ Si Aún Falla

Si después de redesplegar sigues viendo errores:

1. **Ver el error exacto:**
   ```bash
   sudo tail -100 /opt/tomcat/logs/catalina.out | grep -A 20 -i error
   ```

2. **El error más probable ahora es:** Variables de entorno no configuradas

3. **Solución:**
   ```bash
   ./configurar-variables-entorno.sh /opt/tomcat
   sudo systemctl restart tomcat
   ```

---

## 📋 Comandos Completos (Todo en Uno)

Si quieres hacer todo de una vez, copia y pega:

```bash
# 1. Rebuild
sudo rm -rf target/
./mvnw package -DskipTests

# 2. Redesplegar
sudo systemctl stop tomcat
sudo rm -rf /opt/tomcat/webapps/logitrack*
sudo cp target/logitrack.war /opt/tomcat/webapps/
sudo chown tomcat:tomcat /opt/tomcat/webapps/logitrack.war
sudo systemctl start tomcat

# 3. Ver logs
sudo tail -f /opt/tomcat/logs/catalina.out
# Presiona Ctrl+C cuando veas "Started LogitrackApplication"
```

---

## ✅ Checklist de Verificación

- [ ] WAR reconstruido (ver `ls -lh target/logitrack.war`)
- [ ] WAR copiado a Tomcat (`/opt/tomcat/webapps/logitrack.war`)
- [ ] Tomcat iniciado (`sudo systemctl status tomcat`)
- [ ] Log muestra "Started LogitrackApplication"
- [ ] Base de datos creada (`logitrack_db`)
- [ ] Usuario admin creado
- [ ] Login funciona correctamente

---

**¡El problema del servidor embebido está corregido!**

Ahora solo necesitas reconstruir y redesplegar siguiendo estos pasos.
