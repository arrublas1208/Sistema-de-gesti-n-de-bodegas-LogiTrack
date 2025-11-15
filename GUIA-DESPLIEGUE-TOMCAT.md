# Guía Completa de Despliegue en Tomcat - LogiTrack

**Sistema de Gestión de Bodegas LogiTrack**
**Versión:** 1.0
**Fecha:** Noviembre 2025

---

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Instalación de Dependencias](#instalación-de-dependencias)
3. [Configuración de la Base de Datos](#configuración-de-la-base-de-datos)
4. [Configuración de Variables de Entorno](#configuración-de-variables-de-entorno)
5. [Construcción del Proyecto](#construcción-del-proyecto)
6. [Despliegue en Tomcat](#despliegue-en-tomcat)
7. [Verificación del Despliegue](#verificación-del-despliegue)
8. [Solución de Problemas](#solución-de-problemas)

---

## 🔧 Requisitos Previos

### Software Necesario

| Software | Versión Mínima | Versión Recomendada | Notas |
|----------|----------------|---------------------|-------|
| Java JDK | 17 | 17+ | **CRÍTICO: Spring Boot 3.4 requiere Java 17+** |
| Apache Tomcat | 10.0 | 10.1.x | Tomcat 10+ usa Jakarta EE (requerido para Spring Boot 3.x) |
| MySQL | 8.0 | 8.0+ | Base de datos |
| Maven | 3.6+ | 3.9+ | Incluido en el proyecto (mvnw) |

### Hardware Recomendado

- **RAM:** Mínimo 2GB, recomendado 4GB
- **Disco:** 500MB libres
- **CPU:** 2 cores o más

---

## 📥 Instalación de Dependencias

### Paso 1: Instalar Java 17

#### Opción A: Instalación Automática (Linux)

```bash
# Ejecutar el script incluido
sudo ./instalar-java17.sh
```

#### Opción B: Instalación Manual

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install openjdk-17-jdk openjdk-17-jre
sudo update-alternatives --config java
sudo update-alternatives --config javac
```

**CentOS/RHEL/Fedora:**
```bash
sudo yum install java-17-openjdk java-17-openjdk-devel
```

**Windows:**
1. Descargar desde: https://adoptium.net/
2. Ejecutar instalador
3. Configurar `JAVA_HOME` en variables de entorno del sistema

#### Verificar Instalación de Java

```bash
java -version
# Debe mostrar: openjdk version "17.x.x" o superior

javac -version
# Debe mostrar: javac 17.x.x o superior
```

⚠️ **IMPORTANTE:** Si `java -version` no muestra versión 17, el build fallará.

---

### Paso 2: Instalar Apache Tomcat 10

#### Opción A: Descarga Manual

1. Ir a: https://tomcat.apache.org/download-10.cgi
2. Descargar "Core" → "tar.gz" (Linux) o "zip" (Windows)
3. Extraer en ubicación deseada

**Linux:**
```bash
cd /opt
sudo wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.33/bin/apache-tomcat-10.1.33.tar.gz
sudo tar -xzf apache-tomcat-10.1.33.tar.gz
sudo ln -s apache-tomcat-10.1.33 tomcat
sudo chmod +x /opt/tomcat/bin/*.sh
```

**Windows:**
```cmd
# Extraer el ZIP en C:\apache-tomcat-10.1.33
# Crear variable de entorno CATALINA_HOME
set CATALINA_HOME=C:\apache-tomcat-10.1.33
```

#### Opción B: Instalación via Gestor de Paquetes

**Ubuntu/Debian:**
```bash
sudo apt install tomcat10
# CATALINA_HOME estará en: /var/lib/tomcat10
```

#### Verificar Instalación de Tomcat

```bash
# Linux
$CATALINA_HOME/bin/version.sh

# Windows
%CATALINA_HOME%\bin\version.bat
```

Debe mostrar: "Server version: Apache Tomcat/10.x.x"

---

### Paso 3: Instalar y Configurar MySQL

#### Instalación

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql
```

**Windows:**
1. Descargar desde: https://dev.mysql.com/downloads/installer/
2. Ejecutar instalador
3. Configurar contraseña de root

#### Verificar MySQL

```bash
sudo systemctl status mysql    # Linux
# o
net start MySQL                # Windows

mysql --version
# Debe mostrar: mysql Ver 8.0.x
```

---

## 🗄️ Configuración de la Base de Datos

### Paso 1: Crear Base de Datos y Usuario

Conectarse a MySQL:
```bash
mysql -u root -p
```

Ejecutar los siguientes comandos SQL:

```sql
-- Crear base de datos
CREATE DATABASE IF NOT EXISTS logitrack_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- Crear usuario (CAMBIAR contraseña en producción)
CREATE USER IF NOT EXISTS 'logitrack_user'@'localhost'
  IDENTIFIED BY 'TuContraseñaSegura123!';

-- Otorgar permisos
GRANT ALL PRIVILEGES ON logitrack_db.* TO 'logitrack_user'@'localhost';
FLUSH PRIVILEGES;

-- Verificar
SHOW DATABASES;
SELECT User, Host FROM mysql.user WHERE User = 'logitrack_user';

EXIT;
```

### Paso 2: Crear Usuario Administrador Inicial

**IMPORTANTE:** Como el endpoint de registro de admins está protegido, debes crear el primer admin manualmente.

```sql
-- Conectarse a la base de datos
mysql -u root -p logitrack_db

-- Insertar empresa
INSERT INTO empresa (nombre) VALUES ('Mi Empresa');

-- Insertar usuario admin
-- Contraseña hasheada con BCrypt para: Admin123!
INSERT INTO usuario (
  username,
  password,
  rol,
  nombre_completo,
  email,
  cedula,
  empresa_id
) VALUES (
  'admin',
  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
  'ADMIN',
  'Administrador Principal',
  'admin@logitrack.com',
  '1234567890',
  1
);

-- Verificar
SELECT username, rol, nombre_completo FROM usuario;

EXIT;
```

**Credenciales del Admin:**
- **Usuario:** `admin`
- **Contraseña:** `Admin123!`

⚠️ **CAMBIAR esta contraseña después del primer login!**

---

## ⚙️ Configuración de Variables de Entorno

Las variables de entorno configuran la conexión a la base de datos, JWT, CORS, etc.

### Opción A: Script Automático (Recomendado)

```bash
# Ejecutar el script de configuración
./configurar-variables-entorno.sh /ruta/a/tomcat

# Ejemplo:
./configurar-variables-entorno.sh /opt/tomcat
```

El script te guiará paso a paso para configurar:
- Conexión a MySQL
- JWT Secret
- CORS Origins
- Otras configuraciones

### Opción B: Configuración Manual

Crear archivo: `$CATALINA_HOME/bin/setenv.sh` (Linux) o `setenv.bat` (Windows)

**Linux - setenv.sh:**
```bash
#!/bin/bash

# Configuración de Base de Datos
export DB_URL="jdbc:mysql://localhost:3306/logitrack_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true"
export DB_USERNAME="logitrack_user"
export DB_PASSWORD="TuContraseñaSegura123!"

# Configuración de JWT
# ⚠️ GENERAR UN SECRETO SEGURO PARA PRODUCCIÓN:
# openssl rand -base64 64
export JWT_SECRET="CHANGE-THIS-SECRET-IN-PRODUCTION-USE-AT-LEAST-256-BITS-RANDOM-STRING-HERE!!"
export JWT_VALIDITY_MS=3600000

# Configuración de CORS
export CORS_ALLOWED_ORIGINS="http://localhost:8080,http://localhost:5173"

# Configuración de JVM
export CATALINA_OPTS="$CATALINA_OPTS -Xms512m -Xmx1024m"
export CATALINA_OPTS="$CATALINA_OPTS -XX:+UseG1GC"
```

Dar permisos de ejecución:
```bash
chmod +x $CATALINA_HOME/bin/setenv.sh
chmod 600 $CATALINA_HOME/bin/setenv.sh  # Proteger contraseñas
```

**Windows - setenv.bat:**
```batch
@echo off

set DB_URL=jdbc:mysql://localhost:3306/logitrack_db?useSSL=false^&serverTimezone=UTC^&allowPublicKeyRetrieval=true
set DB_USERNAME=logitrack_user
set DB_PASSWORD=TuContraseñaSegura123!

set JWT_SECRET=CHANGE-THIS-SECRET-IN-PRODUCTION-USE-AT-LEAST-256-BITS-RANDOM-STRING-HERE!!
set JWT_VALIDITY_MS=3600000

set CORS_ALLOWED_ORIGINS=http://localhost:8080,http://localhost:5173

set CATALINA_OPTS=%CATALINA_OPTS% -Xms512m -Xmx1024m
```

---

## 🔨 Construcción del Proyecto

### Opción A: Script Automático (Recomendado)

```bash
# Build simple (sin despliegue)
./build-y-desplegar.sh

# Build + Despliegue automático en Tomcat
./build-y-desplegar.sh /opt/tomcat
```

### Opción B: Build Manual

```bash
# Limpiar builds anteriores
./mvnw clean

# Construir WAR (saltando tests para velocidad)
./mvnw package -DskipTests

# O con tests (toma más tiempo)
./mvnw package
```

**Verificar el WAR generado:**
```bash
ls -lh target/logitrack.war
# Debe mostrar un archivo de ~30-50 MB
```

---

## 🚀 Despliegue en Tomcat

### Método 1: Despliegue Automático con Script

```bash
./build-y-desplegar.sh /opt/tomcat
```

Este script:
1. ✅ Verifica Java 17
2. ✅ Verifica MySQL
3. ✅ Construye el WAR
4. ✅ Detiene Tomcat
5. ✅ Copia el WAR a webapps
6. ✅ Inicia Tomcat

---

### Método 2: Despliegue Manual

#### Paso 1: Detener Tomcat (si está corriendo)

```bash
# Linux
$CATALINA_HOME/bin/shutdown.sh

# Windows
%CATALINA_HOME%\bin\shutdown.bat
```

#### Paso 2: Eliminar Despliegue Anterior (si existe)

```bash
# Linux
rm -rf $CATALINA_HOME/webapps/logitrack*

# Windows
rmdir /s /q %CATALINA_HOME%\webapps\logitrack
del %CATALINA_HOME%\webapps\logitrack.war
```

#### Paso 3: Copiar WAR a Tomcat

```bash
# Linux
cp target/logitrack.war $CATALINA_HOME/webapps/

# Windows
copy target\logitrack.war %CATALINA_HOME%\webapps\
```

#### Paso 4: Iniciar Tomcat

```bash
# Linux
$CATALINA_HOME/bin/startup.sh

# Windows
%CATALINA_HOME%\bin\startup.bat
```

Tomcat desempaquetará automáticamente el WAR en `webapps/logitrack/`

---

### Método 3: Tomcat Manager (Web UI)

1. **Iniciar Tomcat:**
   ```bash
   $CATALINA_HOME/bin/startup.sh
   ```

2. **Acceder a Tomcat Manager:**
   - URL: http://localhost:8080/manager/html
   - Usuario/Contraseña: Configurados en `$CATALINA_HOME/conf/tomcat-users.xml`

3. **Desplegar WAR:**
   - Scroll a "WAR file to deploy"
   - Click "Choose File" → Seleccionar `target/logitrack.war`
   - Click "Deploy"

---

## ✅ Verificación del Despliegue

### 1. Verificar Logs de Tomcat

```bash
# Ver logs en tiempo real
tail -f $CATALINA_HOME/logs/catalina.out
```

**Buscar en los logs:**

✅ **Mensajes de éxito:**
```
Started LogitrackApplication in X.XXX seconds
Tomcat started on port(s): 8080
```

❌ **Errores comunes:**
```
Error creating bean...                    # Error de configuración
Access denied for user...                 # Error de MySQL
Unable to acquire JDBC Connection...      # MySQL no está corriendo
```

### 2. Verificar Estado del Despliegue

```bash
# Verificar que el directorio se desempaquetó
ls -la $CATALINA_HOME/webapps/logitrack/

# Debe mostrar:
# WEB-INF/
# META-INF/
# index.html (si existe frontend)
```

### 3. Probar la Aplicación

#### A. Acceso Web

Abrir navegador y acceder a:
```
http://localhost:8080/logitrack/
```

#### B. Probar API de Login

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
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "type": "Bearer",
  "username": "admin",
  "rol": "ADMIN"
}
```

#### C. Acceder a Swagger UI

```
http://localhost:8080/logitrack/swagger-ui.html
```

Deberías ver la documentación interactiva de la API.

### 4. Verificar Base de Datos

```sql
-- Conectarse a MySQL
mysql -u logitrack_user -p logitrack_db

-- Verificar tablas creadas
SHOW TABLES;

-- Debe mostrar:
-- auditoria, bodega, categoria, empresa,
-- inventario, movimiento, producto, usuario

-- Verificar usuario admin
SELECT username, rol FROM usuario WHERE rol = 'ADMIN';

EXIT;
```

---

## 🐛 Solución de Problemas

### Problema 1: "release version 17 not supported"

**Causa:** Java 11 o inferior instalado.

**Solución:**
```bash
# Verificar versión
java -version

# Si no es 17+, instalar Java 17
sudo ./instalar-java17.sh

# O manualmente
sudo apt install openjdk-17-jdk
sudo update-alternatives --config java  # Seleccionar Java 17
```

---

### Problema 2: Error 404 - Aplicación no encontrada

**Causa:** WAR no desplegado o context path incorrecto.

**Solución:**
```bash
# 1. Verificar que el WAR existe
ls -la $CATALINA_HOME/webapps/logitrack.war

# 2. Verificar que se desempaquetó
ls -la $CATALINA_HOME/webapps/logitrack/

# 3. Ver logs de despliegue
tail -100 $CATALINA_HOME/logs/catalina.out | grep -i logitrack

# 4. Si no se desempaquetó, intentar manualmente
cd $CATALINA_HOME/webapps
unzip logitrack.war -d logitrack/
```

**URL correcta:**
- ✅ `http://localhost:8080/logitrack/` (con slash final)
- ❌ `http://localhost:8080/logitrack` (sin slash)

---

### Problema 3: Error de Conexión a MySQL

**Error en logs:**
```
Unable to acquire JDBC Connection
Access denied for user 'logitrack_user'@'localhost'
```

**Solución:**

1. **Verificar que MySQL esté corriendo:**
   ```bash
   # Linux
   sudo systemctl status mysql
   sudo systemctl start mysql    # Si no está corriendo

   # Windows
   net start MySQL
   ```

2. **Verificar credenciales:**
   ```bash
   mysql -u logitrack_user -p logitrack_db
   # Si falla, recrear usuario (ver sección de MySQL)
   ```

3. **Verificar variables de entorno:**
   ```bash
   # Verificar que setenv.sh existe y tiene permisos
   ls -la $CATALINA_HOME/bin/setenv.sh

   # Ver si las variables se cargan (reiniciar Tomcat primero)
   grep -i "DB_URL" $CATALINA_HOME/logs/catalina.out
   ```

4. **Verificar que la base de datos existe:**
   ```sql
   mysql -u root -p -e "SHOW DATABASES LIKE 'logitrack_db';"
   ```

---

### Problema 4: Error 401 Unauthorized en todas las requests

**Causa:** JWT_SECRET no configurado o incorrecto.

**Solución:**

1. **Verificar JWT_SECRET en setenv.sh:**
   ```bash
   grep JWT_SECRET $CATALINA_HOME/bin/setenv.sh
   ```

2. **Generar nuevo JWT_SECRET seguro:**
   ```bash
   openssl rand -base64 64
   # Copiar resultado a setenv.sh
   ```

3. **Reiniciar Tomcat** (IMPORTANTE):
   ```bash
   $CATALINA_HOME/bin/shutdown.sh
   sleep 3
   $CATALINA_HOME/bin/startup.sh
   ```

4. **Probar login nuevamente:**
   ```bash
   curl -X POST http://localhost:8080/logitrack/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"username":"admin","password":"Admin123!"}'
   ```

---

### Problema 5: CORS Error desde Frontend

**Error en navegador:**
```
Access to XMLHttpRequest blocked by CORS policy
```

**Solución:**

1. **Verificar CORS_ALLOWED_ORIGINS:**
   ```bash
   grep CORS $CATALINA_HOME/bin/setenv.sh
   ```

2. **Actualizar setenv.sh:**
   ```bash
   # Incluir el origen de tu frontend
   export CORS_ALLOWED_ORIGINS="http://localhost:5173,http://localhost:3000,http://localhost:8080"
   ```

3. **Reiniciar Tomcat:**
   ```bash
   $CATALINA_HOME/bin/shutdown.sh && $CATALINA_HOME/bin/startup.sh
   ```

**IMPORTANTE:** Los orígenes NO deben terminar en `/`
- ✅ `http://localhost:5173`
- ❌ `http://localhost:5173/`

---

### Problema 6: Tomcat no inicia

**Solución:**

1. **Ver logs completos:**
   ```bash
   cat $CATALINA_HOME/logs/catalina.out
   ```

2. **Verificar puerto 8080 no esté ocupado:**
   ```bash
   # Linux
   sudo lsof -i :8080
   # Matar proceso si es necesario
   sudo kill -9 <PID>

   # Windows
   netstat -ano | findstr :8080
   taskkill /PID <PID> /F
   ```

3. **Verificar permisos:**
   ```bash
   # Linux - dar permisos de ejecución
   chmod +x $CATALINA_HOME/bin/*.sh
   ```

4. **Ver errores de Java:**
   ```bash
   $CATALINA_HOME/bin/catalina.sh run
   # Esto ejecuta en primer plano y muestra todos los errores
   ```

---

### Problema 7: Tablas de BD no se crean

**Causa:** `schema.sql` no se ejecutó.

**Solución:**

1. **Verificar archivos SQL existen:**
   ```bash
   ls -la src/main/resources/schema.sql
   ls -la src/main/resources/data.sql
   ```

2. **Ejecutar manualmente:**
   ```bash
   mysql -u logitrack_user -p logitrack_db < src/main/resources/schema.sql
   mysql -u logitrack_user -p logitrack_db < src/main/resources/data.sql
   ```

3. **Verificar application.properties:**
   ```properties
   spring.sql.init.mode=always
   spring.sql.init.schema-locations=classpath:schema.sql
   spring.sql.init.data-locations=classpath:data.sql
   ```

---

## 🔒 Checklist de Seguridad para Producción

Antes de desplegar en producción, asegúrate de:

- [ ] **Cambiar JWT_SECRET** por una clave de 256+ bits aleatoria
  ```bash
  openssl rand -base64 64
  ```

- [ ] **Cambiar contraseña de MySQL** del valor por defecto

- [ ] **Cambiar contraseña del usuario admin** (`Admin123!`)

- [ ] **Configurar CORS** con dominios específicos (no `*`)
  ```bash
  export CORS_ALLOWED_ORIGINS="https://midominio.com"
  ```

- [ ] **Desactivar stack traces** en errores (ya configurado en `application.properties`)
  ```properties
  server.error.include-message=never
  server.error.include-stacktrace=never
  ```

- [ ] **Configurar HTTPS en Tomcat** (certificado SSL/TLS)

- [ ] **Configurar firewall** para permitir solo puertos necesarios

- [ ] **Configurar backups automáticos** de MySQL

- [ ] **Configurar logging** y monitoreo

- [ ] **Revisar permisos de archivos:**
  ```bash
  chmod 600 $CATALINA_HOME/bin/setenv.sh  # Solo lectura para owner
  ```

---

## 📚 Recursos Adicionales

### Archivos de Configuración Incluidos

- `instalar-java17.sh` - Script de instalación de Java 17
- `build-y-desplegar.sh` - Script de build y despliegue automático
- `configurar-variables-entorno.sh` - Script de configuración de variables
- `pom.xml` - Configuración de Maven
- `application.properties` - Configuración de Spring Boot
- `schema.sql` - Esquema de base de datos
- `data.sql` - Datos iniciales

### Enlaces Útiles

- **Tomcat Documentation:** https://tomcat.apache.org/tomcat-10.0-doc/
- **Spring Boot Deployment:** https://docs.spring.io/spring-boot/docs/current/reference/html/deployment.html
- **MySQL Documentation:** https://dev.mysql.com/doc/
- **OpenJDK 17:** https://adoptium.net/

---

## 📝 Resumen de Comandos Rápidos

### Build y Despliegue Automático
```bash
# 1. Instalar Java 17
sudo ./instalar-java17.sh

# 2. Configurar variables de entorno
./configurar-variables-entorno.sh /opt/tomcat

# 3. Build y desplegar
./build-y-desplegar.sh /opt/tomcat

# 4. Ver logs
tail -f /opt/tomcat/logs/catalina.out
```

### Build y Despliegue Manual
```bash
# 1. Build
./mvnw clean package -DskipTests

# 2. Detener Tomcat
$CATALINA_HOME/bin/shutdown.sh

# 3. Desplegar
rm -rf $CATALINA_HOME/webapps/logitrack*
cp target/logitrack.war $CATALINA_HOME/webapps/

# 4. Iniciar Tomcat
$CATALINA_HOME/bin/startup.sh

# 5. Ver logs
tail -f $CATALINA_HOME/logs/catalina.out
```

---

## 🆘 Soporte

Si encuentras problemas durante el despliegue:

1. **Revisa los logs:** `$CATALINA_HOME/logs/catalina.out`
2. **Verifica las variables de entorno** en `setenv.sh`
3. **Asegúrate de que MySQL esté corriendo**
4. **Verifica que Java 17 esté instalado y configurado**
5. **Consulta la sección de Solución de Problemas** de esta guía

---

**¡Despliegue exitoso!** 🎉

Si todos los pasos se completaron correctamente, LogiTrack debería estar corriendo en:
- **Aplicación:** http://localhost:8080/logitrack/
- **Swagger UI:** http://localhost:8080/logitrack/swagger-ui.html
- **Login:** `admin` / `Admin123!`

