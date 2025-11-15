# 🚀 Inicio Rápido - LogiTrack Tomcat

## Pasos para Desplegar (5 minutos)

### ✅ Pre-requisitos

Antes de comenzar, necesitas:
- [x] Tomcat 10.x instalado
- [x] MySQL 8.x instalado y corriendo
- [x] Permisos de administrador (sudo)

---

## 📋 Guía de 5 Pasos

### 1️⃣ Instalar Java 17

```bash
sudo ./instalar-java17.sh
```

Espera a que termine y verifica:
```bash
java -version
# Debe mostrar: openjdk version "17.x.x"
```

---

### 2️⃣ Configurar MySQL

```bash
# Conectarse a MySQL
mysql -u root -p

# Copiar y pegar estos comandos:
```

```sql
CREATE DATABASE IF NOT EXISTS logitrack_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'logitrack_user'@'localhost' IDENTIFIED BY 'TuContraseña123!';
GRANT ALL PRIVILEGES ON logitrack_db.* TO 'logitrack_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

---

### 3️⃣ Configurar Variables de Entorno

```bash
./configurar-variables-entorno.sh /ruta/a/tomcat

# Ejemplo:
./configurar-variables-entorno.sh /opt/tomcat
```

Seguir las instrucciones del script (ingresa contraseñas, etc.)

---

### 4️⃣ Build y Desplegar

```bash
./build-y-desplegar.sh /opt/tomcat
```

Este script hará todo automáticamente:
- ✅ Verificar Java 17
- ✅ Limpiar builds anteriores
- ✅ Construir WAR
- ✅ Detener Tomcat
- ✅ Copiar WAR
- ✅ Iniciar Tomcat

---

### 5️⃣ Crear Usuario Admin

```bash
# Conectarse a la base de datos
mysql -u root -p logitrack_db

# Copiar y pegar:
```

```sql
INSERT INTO empresa (nombre) VALUES ('Mi Empresa');

INSERT INTO usuario (username, password, rol, nombre_completo, email, cedula, empresa_id)
VALUES (
  'admin',
  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
  'ADMIN',
  'Administrador Principal',
  'admin@logitrack.com',
  '1234567890',
  1
);

EXIT;
```

---

## 🎉 ¡Listo!

Accede a la aplicación:

- **Aplicación:** http://localhost:8080/logitrack/
- **Swagger UI:** http://localhost:8080/logitrack/swagger-ui.html
- **Login:**
  - Usuario: `admin`
  - Contraseña: `Admin123!`

---

## 🐛 ¿Problemas?

### Ver logs:
```bash
tail -f /opt/tomcat/logs/catalina.out
```

### Reiniciar Tomcat:
```bash
/opt/tomcat/bin/shutdown.sh
sleep 3
/opt/tomcat/bin/startup.sh
```

### Verificar MySQL:
```bash
sudo systemctl status mysql
sudo systemctl start mysql  # Si no está corriendo
```

---

## 📖 Documentación Completa

Para más detalles, ver: **GUIA-DESPLIEGUE-TOMCAT.md**

---

## ⚡ Comandos Útiles

```bash
# Ver logs en tiempo real
tail -f /opt/tomcat/logs/catalina.out

# Detener Tomcat
/opt/tomcat/bin/shutdown.sh

# Iniciar Tomcat
/opt/tomcat/bin/startup.sh

# Rebuild sin desplegar
./mvnw clean package -DskipTests

# Rebuild y redesplegar
./build-y-desplegar.sh /opt/tomcat
```

---

## 🔒 Recordatorios de Seguridad

⚠️ **ANTES DE PRODUCCIÓN:**

1. Cambiar contraseña del admin (`Admin123!`)
2. Cambiar contraseña de MySQL
3. Generar nuevo JWT_SECRET seguro
4. Configurar CORS con tu dominio real
5. Configurar HTTPS

---

## 🆘 Ayuda Rápida

| Problema | Solución |
|----------|----------|
| Error "release version 17 not supported" | Ejecutar `sudo ./instalar-java17.sh` |
| Error 404 | Verificar URL: `http://localhost:8080/logitrack/` (con /) |
| Error de MySQL | Ejecutar `sudo systemctl start mysql` |
| Error 401 | Verificar setenv.sh y reiniciar Tomcat |
| CORS Error | Agregar tu dominio a CORS_ALLOWED_ORIGINS |

Ver **GUIA-DESPLIEGUE-TOMCAT.md** para soluciones detalladas.
