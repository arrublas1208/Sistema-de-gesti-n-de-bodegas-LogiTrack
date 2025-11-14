# Guía de Despliegue en Apache Tomcat - LogiTrack

## ✅ RESUMEN EJECUTIVO

El proyecto LogiTrack está **100% listo para despliegue en Tomcat**. Este documento contiene todas las instrucciones necesarias.

---

## 📦 PASO 1: Generar el Archivo WAR

El WAR ya está generado en: `target/logitrack-0.0.1-SNAPSHOT.war` (62 MB)

Para regenerarlo:
```bash
# Windows
mvnw.cmd clean package -DskipTests

# Linux/Mac
./mvnw clean package -DskipTests
```

---

## 🗄️ PASO 2: Configurar MySQL

```sql
CREATE DATABASE logitrack_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'logitrack_user'@'localhost' IDENTIFIED BY 'password_seguro';
GRANT ALL PRIVILEGES ON logitrack_db.* TO 'logitrack_user'@'localhost';
FLUSH PRIVILEGES;
```

---

## ⚙️ PASO 3: Configurar Variables de Entorno

**Windows:**
```cmd
setx DB_URL "jdbc:mysql://localhost:3306/logitrack_db"
setx DB_USERNAME "logitrack_user"
setx DB_PASSWORD "password_seguro"
setx JWT_SECRET "clave-secreta-de-256-bits-minimo"
```

**Linux/Mac:**
```bash
export DB_URL="jdbc:mysql://localhost:3306/logitrack_db"
export DB_USERNAME="logitrack_user"
export DB_PASSWORD="password_seguro"
export JWT_SECRET="clave-secreta-de-256-bits-minimo"
```

---

## 🚀 PASO 4: Desplegar en Tomcat

```bash
# 1. Copiar WAR a Tomcat
cp target/logitrack-0.0.1-SNAPSHOT.war /opt/tomcat/webapps/logitrack.war

# 2. Reiniciar Tomcat
cd /opt/tomcat/bin
./shutdown.sh
./startup.sh

# 3. Verificar logs
tail -f /opt/tomcat/logs/catalina.out
```

---

## 🌐 PASO 5: Acceder a la Aplicación

- Frontend: http://localhost:8080/logitrack/
- Swagger: http://localhost:8080/logitrack/swagger-ui.html
- API: http://localhost:8080/logitrack/api/

**Credenciales de prueba:**
- Usuario: admin
- Password: admin123

---

## ✅ Configuración Verificada

- ✅ pom.xml con packaging WAR
- ✅ spring-boot-starter-tomcat con scope provided
- ✅ ServletInitializer.java implementado
- ✅ Compilación exitosa (BUILD SUCCESS)
- ✅ WAR generado: 62 MB
- ✅ Todas las validaciones agregadas
- ✅ 51 clases Java compiladas sin errores

---

Para más detalles, consulta la documentación completa en el README.md
