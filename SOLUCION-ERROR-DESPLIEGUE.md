# Solución al Error de Despliegue en Tomcat

## ❌ Error Actual

```
FAIL - Application at context path [/logitrack] could not be started
FAIL - Encountered exception [org.apache.catalina.LifecycleException: Failed to start component]
```

---

## ✅ Verificaciones Realizadas

- ✓ **Java 17** instalado y funcionando
- ✓ **WAR compilado con Java 17** (Build-Jdk-Spec: 17)
- ✓ **MySQL** está corriendo
- ✓ **WAR existe** en target/logitrack.war (64 MB)

---

## 🔍 Diagnóstico del Error

Para ver el error exacto, ejecuta:

```bash
sudo ./revisar-error-despliegue.sh
```

Este script te mostrará:
1. Los logs de Tomcat con el error específico
2. Estado de MySQL
3. Variables de entorno configuradas
4. Si el WAR se desempaquetó correctamente

---

## 🔧 Soluciones a Problemas Comunes

### Problema 1: Variables de Entorno NO Configuradas

**Síntoma en logs:**
```
Could not resolve placeholder 'DB_URL'
Could not resolve placeholder 'JWT_SECRET'
```

**SOLUCIÓN:**

```bash
# Configurar variables de entorno para Tomcat
./configurar-variables-entorno.sh /opt/tomcat

# O crearlas manualmente
sudo nano /opt/tomcat/bin/setenv.sh
```

Contenido de `/opt/tomcat/bin/setenv.sh`:

```bash
#!/bin/bash

# Base de datos
export DB_URL="jdbc:mysql://localhost:3306/logitrack_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true"
export DB_USERNAME="logitrack_user"
export DB_PASSWORD="TuContraseña123!"

# JWT
export JWT_SECRET="CHANGE-THIS-IN-PRODUCTION-USE-256-BITS-RANDOM-STRING"
export JWT_VALIDITY_MS=3600000

# CORS
export CORS_ALLOWED_ORIGINS="http://localhost:8080"
```

Dar permisos:
```bash
sudo chmod +x /opt/tomcat/bin/setenv.sh
sudo chmod 600 /opt/tomcat/bin/setenv.sh
```

**Reiniciar Tomcat:**
```bash
sudo systemctl restart tomcat
```

---

### Problema 2: Error de Conexión a Base de Datos

**Síntoma en logs:**
```
Unable to acquire JDBC Connection
Access denied for user 'logitrack_user'@'localhost'
Unknown database 'logitrack_db'
```

**SOLUCIÓN:**

```bash
# 1. Verificar que MySQL está corriendo
sudo systemctl status mysql

# 2. Crear base de datos y usuario
mysql -u root -p
```

```sql
-- Crear base de datos
CREATE DATABASE IF NOT EXISTS logitrack_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- Crear usuario
CREATE USER IF NOT EXISTS 'logitrack_user'@'localhost'
  IDENTIFIED BY 'TuContraseña123!';

-- Dar permisos
GRANT ALL PRIVILEGES ON logitrack_db.* TO 'logitrack_user'@'localhost';
FLUSH PRIVILEGES;

-- Verificar
SHOW DATABASES LIKE 'logitrack_db';
SELECT User, Host FROM mysql.user WHERE User = 'logitrack_user';

EXIT;
```

---

### Problema 3: Tablas No Se Crean Automáticamente

**Síntoma en logs:**
```
Table 'logitrack_db.usuario' doesn't exist
```

**SOLUCIÓN:**

Las tablas deberían crearse automáticamente con `schema.sql`, pero si no:

```bash
# Ejecutar scripts SQL manualmente
cd /home/CAMPER/Desktop/Sistema-de-gesti-n-de-bodegas-LogiTrack

mysql -u logitrack_user -p logitrack_db < src/main/resources/schema.sql
mysql -u logitrack_user -p logitrack_db < src/main/resources/data.sql
```

---

### Problema 4: Error de ClassNotFoundException

**Síntoma en logs:**
```
java.lang.ClassNotFoundException: org.springframework.boot...
```

**SOLUCIÓN:**

El WAR está corrupto o incompleto. Reconstruir:

```bash
# Limpiar todo
./mvnw clean

# Verificar que Java 17 está activo
java -version
# Debe mostrar versión 17

# Reconstruir
./mvnw package -DskipTests

# Verificar tamaño del WAR (debe ser ~60-70 MB)
ls -lh target/logitrack.war
```

---

### Problema 5: Puerto 8080 Ocupado

**Síntoma:**
```
Address already in use
java.net.BindException: Address already in use
```

**SOLUCIÓN:**

```bash
# Ver qué está usando el puerto 8080
sudo lsof -i :8080

# Matar el proceso
sudo kill -9 <PID>

# O cambiar puerto de Tomcat
sudo nano /opt/tomcat/conf/server.xml
# Cambiar: <Connector port="8080" ...
```

---

### Problema 6: Permisos Incorrectos

**Síntoma:**
```
Permission denied
Cannot read configuration file
```

**SOLUCIÓN:**

```bash
# Dar permisos correctos al WAR
sudo chmod 644 /opt/tomcat/webapps/logitrack.war

# Dar permisos a Tomcat para escribir en webapps
sudo chown -R tomcat:tomcat /opt/tomcat/webapps/
```

---

## 🔄 Procedimiento Completo de Redespliegue

Si nada funciona, haz un redespliegue limpio:

```bash
# 1. Detener Tomcat
sudo systemctl stop tomcat

# 2. Eliminar despliegue anterior
sudo rm -rf /opt/tomcat/webapps/logitrack*

# 3. Limpiar logs antiguos (opcional)
sudo rm -f /opt/tomcat/logs/catalina.out

# 4. Asegurarse de que setenv.sh existe y tiene las variables correctas
ls -la /opt/tomcat/bin/setenv.sh

# Si no existe, crearlo:
./configurar-variables-entorno.sh /opt/tomcat

# 5. Verificar MySQL
sudo systemctl status mysql
mysql -u logitrack_user -p -e "SHOW DATABASES LIKE 'logitrack_db';"

# 6. Copiar nuevo WAR
sudo cp target/logitrack.war /opt/tomcat/webapps/

# 7. Dar permisos
sudo chown tomcat:tomcat /opt/tomcat/webapps/logitrack.war
sudo chmod 644 /opt/tomcat/webapps/logitrack.war

# 8. Iniciar Tomcat
sudo systemctl start tomcat

# 9. Ver logs en tiempo real
sudo tail -f /opt/tomcat/logs/catalina.out

# Esperar a ver:
# "Started LogitrackApplication in X.XXX seconds"
```

---

## 📊 Verificar que Funcionó

Una vez que Tomcat inicie sin errores:

### 1. Verificar que la app se desempaquetó

```bash
ls -la /opt/tomcat/webapps/logitrack/
# Debe mostrar: WEB-INF/, META-INF/, etc.
```

### 2. Probar el endpoint de login

```bash
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

### 3. Acceder por navegador

- **Aplicación:** http://localhost:8080/logitrack/
- **Swagger:** http://localhost:8080/logitrack/swagger-ui.html

---

## 🆘 Si Aún No Funciona

1. **Ejecuta el diagnóstico:**
   ```bash
   sudo ./revisar-error-despliegue.sh > diagnostico.txt
   ```

2. **Busca en el archivo `diagnostico.txt` las palabras:**
   - `Exception`
   - `Error`
   - `Failed`
   - `Cannot`

3. **Copia el error exacto** y búscalo en Google o consulta la documentación

4. **Verifica que creaste el usuario admin en la base de datos:**
   ```sql
   mysql -u logitrack_user -p logitrack_db
   SELECT * FROM usuario WHERE rol = 'ADMIN';
   ```

---

## 📝 Checklist de Verificación

Antes de redesplegar, asegúrate de que:

- [ ] Java 17 está instalado: `java -version`
- [ ] MySQL está corriendo: `sudo systemctl status mysql`
- [ ] Base de datos existe: `mysql -u root -p -e "SHOW DATABASES;"`
- [ ] Usuario de BD existe: `mysql -u logitrack_user -p -e "SELECT 1;"`
- [ ] Variables de entorno configuradas: `ls /opt/tomcat/bin/setenv.sh`
- [ ] WAR compilado correctamente: `ls -lh target/logitrack.war` (~60MB)
- [ ] Tomcat tiene permisos en webapps: `ls -la /opt/tomcat/webapps/`

---

## 📞 Comandos Útiles

```bash
# Ver logs en tiempo real
sudo tail -f /opt/tomcat/logs/catalina.out

# Ver últimos 100 errores
sudo grep -i error /opt/tomcat/logs/catalina.out | tail -100

# Reiniciar Tomcat
sudo systemctl restart tomcat

# Ver status de Tomcat
sudo systemctl status tomcat

# Detener Tomcat
sudo systemctl stop tomcat

# Iniciar Tomcat
sudo systemctl start tomcat

# Ver procesos de Tomcat
ps aux | grep tomcat

# Ver qué está en el puerto 8080
sudo lsof -i :8080
```

---

## ⚡ Solución Rápida (Resumen)

```bash
# 1. Configurar variables
./configurar-variables-entorno.sh /opt/tomcat

# 2. Verificar MySQL
sudo systemctl start mysql

# 3. Crear base de datos (si no existe)
mysql -u root -p < crear-bd.sql

# 4. Redesplegar
sudo systemctl stop tomcat
sudo rm -rf /opt/tomcat/webapps/logitrack*
sudo cp target/logitrack.war /opt/tomcat/webapps/
sudo chown tomcat:tomcat /opt/tomcat/webapps/logitrack.war
sudo systemctl start tomcat

# 5. Ver logs
sudo tail -f /opt/tomcat/logs/catalina.out
```

---

**La causa #1 de este error es: Variables de entorno NO configuradas**

Ejecuta: `./configurar-variables-entorno.sh /opt/tomcat` primero!
