# Guía Completa de Despliegue en Tomcat - LogiTrack

## ✅ Pre-requisitos Completados

- ✅ Build del proyecto completado exitosamente
- ✅ Archivo WAR generado: `target/logitrack-0.0.1-SNAPSHOT.war`
- ✅ Correcciones críticas de seguridad implementadas
- ✅ Frontend construido e integrado

## 📦 Archivo de Despliegue

**Ubicación del WAR:**
```
C:\Users\arrublas\Desktop\springboot\Sistema-de-gesti-n-de-bodegas-LogiTrack\target\logitrack-0.0.1-SNAPSHOT.war
```

**Tamaño:** Verificar con `ls -lh target/*.war`

---

## 🚀 Pasos para Desplegar en Tomcat

### Paso 1: Verificar Instalación de Tomcat

```bash
# Verificar que Tomcat esté instalado
# En Windows, buscar:
C:\Program Files\Apache Software Foundation\Tomcat 9.0
# o
C:\Program Files\Apache Software Foundation\Tomcat 10.0
```

Si no tienes Tomcat instalado:
1. Descargar desde: https://tomcat.apache.org/download-90.cgi (Tomcat 9) o Tomcat 10
2. Extraer en una ubicación (ej: `C:\apache-tomcat-9.0.XX`)
3. Configurar variable de entorno `CATALINA_HOME` apuntando a ese directorio

---

### Paso 2: Configurar Variables de Entorno (CRÍTICO)

Antes de desplegar, **DEBES** configurar las variables de entorno. Ver `ENV_CONFIG.md` para detalles completos.

**Opción A: Variables de entorno del sistema (Windows)**

1. Presionar `Win + R`, escribir `sysdm.cpl`, Enter
2. Ir a "Advanced" → "Environment Variables"
3. En "System variables", agregar:

```
DB_URL = jdbc:mysql://localhost:3306/logitrack_db?useSSL=false&serverTimezone=UTC&createDatabaseIfNotExist=true
DB_USERNAME = root
DB_PASSWORD = campus2023
JWT_SECRET = CHANGE-THIS-SECRET-IN-PRODUCTION-USE-AT-LEAST-256-BITS-RANDOM-STRING-HERE!!
JWT_VALIDITY_MS = 3600000
CORS_ALLOWED_ORIGINS = http://localhost:8080
```

**Opción B: Archivo setenv.bat en Tomcat**

Crear archivo: `%CATALINA_HOME%\bin\setenv.bat`

```batch
@echo off
set DB_URL=jdbc:mysql://localhost:3306/logitrack_db?useSSL=false^&serverTimezone=UTC^&createDatabaseIfNotExist=true
set DB_USERNAME=root
set DB_PASSWORD=campus2023
set JWT_SECRET=CHANGE-THIS-SECRET-IN-PRODUCTION-USE-AT-LEAST-256-BITS-RANDOM-STRING-HERE!!
set JWT_VALIDITY_MS=3600000
set CORS_ALLOWED_ORIGINS=http://localhost:8080
```

---

### Paso 3: Configurar MySQL

1. **Asegurarse de que MySQL esté corriendo:**

```bash
# En Windows (CMD como administrador)
net start MySQL
# O verificar en Servicios (services.msc)
```

2. **Crear usuario y base de datos (si no existen):**

```sql
-- Conectarse a MySQL como root
mysql -u root -p

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS logitrack_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Crear usuario (CAMBIAR contraseña en producción)
CREATE USER IF NOT EXISTS 'logitrack_user'@'localhost' IDENTIFIED BY 'campus2023';
GRANT ALL PRIVILEGES ON logitrack_db.* TO 'logitrack_user'@'localhost';
FLUSH PRIVILEGES;

-- Verificar
SHOW DATABASES;
EXIT;
```

3. **La aplicación creará las tablas automáticamente** usando `schema.sql` y `data.sql`

---

### Paso 4: Crear Usuario Admin Inicial

**IMPORTANTE:** Como se protegió el endpoint `/api/auth/register-admin`, necesitas crear el primer usuario admin manualmente en la base de datos.

```sql
-- Conectarse a la base de datos
mysql -u root -p logitrack_db

-- Insertar empresa
INSERT INTO empresa (nombre) VALUES ('Mi Empresa');

-- Insertar usuario admin (contraseña: Admin123!)
-- Nota: Esta es la contraseña hasheada con BCrypt para "Admin123!"
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

-- Verificar
SELECT * FROM usuario;
EXIT;
```

**Credenciales del admin inicial:**
- **Username:** `admin`
- **Password:** `Admin123!`

---

### Paso 5: Desplegar el WAR en Tomcat

**Método 1: Usando Tomcat Manager (Recomendado)**

1. Iniciar Tomcat:
```bash
# Windows
%CATALINA_HOME%\bin\startup.bat

# Linux/Mac
$CATALINA_HOME/bin/startup.sh
```

2. Abrir navegador: http://localhost:8080/manager/html

3. En "WAR file to deploy", seleccionar:
   ```
   C:\Users\arrublas\Desktop\springboot\Sistema-de-gesti-n-de-bodegas-LogiTrack\target\logitrack-0.0.1-SNAPSHOT.war
   ```

4. Click en "Deploy"

**Método 2: Copiar manualmente (Alternativo)**

1. Detener Tomcat (si está corriendo):
```bash
%CATALINA_HOME%\bin\shutdown.bat
```

2. Copiar el WAR al directorio webapps de Tomcat:
```bash
copy "C:\Users\arrublas\Desktop\springboot\Sistema-de-gesti-n-de-bodegas-LogiTrack\target\logitrack-0.0.1-SNAPSHOT.war" "%CATALINA_HOME%\webapps\logitrack.war"
```

3. Iniciar Tomcat:
```bash
%CATALINA_HOME%\bin\startup.bat
```

4. Tomcat desempaquetará automáticamente el WAR

---

### Paso 6: Verificar el Despliegue

1. **Verificar logs de Tomcat:**

```bash
# Ver logs en tiempo real
tail -f %CATALINA_HOME%\logs\catalina.out
# O en Windows, abrir:
%CATALINA_HOME%\logs\catalina.YYYY-MM-DD.log
```

2. **Buscar en los logs:**
- ✅ `Started LogitrackApplication in X seconds`
- ✅ `Tomcat started on port(s): 8080`
- ❌ Cualquier `ERROR` o `Exception`

3. **Verificar aplicación:**

Abrir en navegador:
```
http://localhost:8080/logitrack/
```

O si renombraste el WAR a `ROOT.war`:
```
http://localhost:8080/
```

4. **Verificar API:**

```bash
# Login con el usuario admin creado
curl -X POST http://localhost:8080/logitrack/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"Admin123!"}'

# Deberías recibir un token JWT
```

5. **Verificar Swagger:**

```
http://localhost:8080/logitrack/swagger-ui.html
```

---

## 🔧 Configuración Avanzada

### Cambiar Context Path

Si quieres que la app esté en la raíz (http://localhost:8080/ en lugar de /logitrack):

**Opción 1:** Renombrar WAR a `ROOT.war`
```bash
copy target\logitrack-0.0.1-SNAPSHOT.war %CATALINA_HOME%\webapps\ROOT.war
```

**Opción 2:** Configurar en `application.properties` (ya configurado):
```properties
server.servlet.context-path=/
```

### Configurar Puerto de Tomcat

Editar `%CATALINA_HOME%\conf\server.xml`:

```xml
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />
```

Cambiar `port="8080"` al puerto deseado.

---

## 🐛 Solución de Problemas

### Problema 1: Error 404 al acceder a la aplicación

**Solución:**
1. Verificar que el WAR se desplegó: Debe existir carpeta `%CATALINA_HOME%\webapps\logitrack\`
2. Verificar URL: `http://localhost:8080/logitrack/` (con / al final)
3. Ver logs: `%CATALINA_HOME%\logs\logitrack.log`

### Problema 2: Error de conexión a base de datos

**Solución:**
1. Verificar que MySQL esté corriendo: `net start MySQL`
2. Verificar credenciales en variables de entorno
3. Verificar que la base de datos existe: `mysql -u root -p -e "SHOW DATABASES;"`
4. Ver logs de Spring Boot en `catalina.out`

### Problema 3: Variables de entorno no reconocidas

**Solución:**
1. Reiniciar completamente Tomcat (shutdown + startup)
2. Verificar que las variables estén configuradas:
   ```bash
   echo %DB_URL%
   echo %JWT_SECRET%
   ```
3. Si usas `setenv.bat`, verificar que esté en `%CATALINA_HOME%\bin\`

### Problema 4: Error 401 Unauthorized en todas las requests

**Solución:**
1. Verificar que el JWT_SECRET esté configurado
2. Intentar login nuevamente: `POST /api/auth/login`
3. Verificar que el token se esté enviando en el header `Authorization: Bearer <token>`

### Problema 5: CORS Error en frontend

**Solución:**
1. Verificar `CORS_ALLOWED_ORIGINS` incluye el origen correcto
2. Para desarrollo local: `http://localhost:8080` (sin / al final)
3. Reiniciar Tomcat después de cambiar

### Problema 6: Error al crear admin (403 Forbidden)

**Solución:**
- El endpoint `/api/auth/register-admin` ahora requiere autenticación de ADMIN
- Crear el primer admin manualmente en la base de datos (ver Paso 4)

---

## 📊 Checklist de Verificación Post-Despliegue

- [ ] Tomcat está corriendo sin errores
- [ ] MySQL está corriendo
- [ ] Base de datos `logitrack_db` existe
- [ ] Usuario admin creado en la base de datos
- [ ] Aplicación accesible en http://localhost:8080/logitrack/
- [ ] Login funciona con `admin` / `Admin123!`
- [ ] Swagger UI accesible
- [ ] Todas las variables de entorno configuradas
- [ ] No hay errores en logs de Tomcat
- [ ] Frontend se carga correctamente

---

## 🔐 Checklist de Seguridad

- [ ] JWT_SECRET cambiado del valor por defecto (CRÍTICO)
- [ ] DB_PASSWORD cambiada del valor por defecto (CRÍTICO)
- [ ] CORS_ALLOWED_ORIGINS configurado con dominios específicos
- [ ] Stack traces desactivados en producción
- [ ] Endpoint register-admin protegido
- [ ] Contraseña del admin cambiada del valor por defecto

---

## 📝 Próximos Pasos Recomendados

### Inmediato (Antes de Producción)
1. **Cambiar todas las contraseñas por defecto**
   - Usuario admin: `Admin123!`
   - Base de datos: `campus2023`
   - JWT secret

2. **Generar JWT secret seguro:**
   ```bash
   # En Git Bash o WSL
   openssl rand -base64 64
   ```

3. **Configurar HTTPS en Tomcat** (ver guía oficial)

### Corto Plazo
4. **Implementar rate limiting** (Spring Cloud Gateway + Resilience4j)
5. **Agregar tests automatizados**
6. **Configurar backup de base de datos**
7. **Implementar logging centralizado**

### Medio Plazo
8. **Refactorizar frontend** (httpOnly cookies, múltiples archivos)
9. **Agregar validación con Zod/Yup**
10. **Implementar refresh tokens**
11. **Agregar MFA (Multi-Factor Authentication)**

---

## 📚 Referencias

- **Documentación de Tomcat:** https://tomcat.apache.org/tomcat-9.0-doc/
- **Spring Boot Deployment:** https://docs.spring.io/spring-boot/docs/current/reference/html/deployment.html
- **MySQL Documentation:** https://dev.mysql.com/doc/
- **ENV_CONFIG.md** - Configuración detallada de variables de entorno
- **Informe de seguridad** - Ver análisis completo de vulnerabilidades

---

## 🆘 Soporte

Si encuentras problemas durante el despliegue:

1. Revisa los logs de Tomcat: `%CATALINA_HOME%\logs\catalina.out`
2. Revisa los logs de la aplicación: `%CATALINA_HOME%\logs\logitrack.log`
3. Verifica la configuración de variables de entorno
4. Asegúrate de que MySQL esté corriendo
5. Verifica que todas las correcciones de seguridad se hayan aplicado

---

**¡El proyecto está listo para desplegar!** 🎉

Recuerda que este despliegue es para **DESARROLLO/QA**. Para producción, implementa las correcciones de seguridad recomendadas en los informes de análisis.
