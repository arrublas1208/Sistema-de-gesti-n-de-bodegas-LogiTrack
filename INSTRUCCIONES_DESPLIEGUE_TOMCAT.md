# 📦 Instrucciones de Despliegue en Tomcat - LogiTrack

## ✅ Estado Actual del Proyecto

- ✅ **Proyecto revisado y corregido**
- ✅ **Schema.sql corregido** (orden correcto de tablas)
- ✅ **WAR generado**: `target/logitrack-0.0.1-SNAPSHOT.war`
- ✅ **Base de datos MySQL configurada**: `logitrack_db`
- ✅ **Datos de prueba insertados**
- ✅ **Usuario demo creado**: `demo/demo123`

---

## 🚀 Opción 1: Ejecutar con Tomcat Embebido (MÁS RÁPIDO)

Si solo quieres probar la aplicación rápidamente:

```bash
cd C:\Users\arrublas\Desktop\springboot\Sistema-de-gesti-n-de-bodegas-LogiTrack
java -jar target/logitrack-0.0.1-SNAPSHOT.war
```

Luego accede a:
- **Frontend**: http://localhost:8081/
- **Swagger**: http://localhost:8081/swagger-ui.html

**Credenciales**: `demo` / `demo123`

---

## 🔧 Opción 2: Desplegar en Tomcat Externo

### Paso 1: Descargar e Instalar Tomcat

1. **Descarga Tomcat 10.1.x** desde:
   ```
   https://tomcat.apache.org/download-10.cgi
   ```

2. **Descarga el archivo**: `apache-tomcat-10.1.x-windows-x64.zip`

3. **Extrae el ZIP** en una ubicación, por ejemplo:
   ```
   C:\apache-tomcat-10.1.x
   ```

### Paso 2: Configurar Variables de Entorno (Opcional)

```cmd
setx CATALINA_HOME "C:\apache-tomcat-10.1.x"
```

### Paso 3: Copiar el WAR a Tomcat

```bash
# Copia el WAR generado a la carpeta webapps de Tomcat
copy "C:\Users\arrublas\Desktop\springboot\Sistema-de-gesti-n-de-bodegas-LogiTrack\target\logitrack-0.0.1-SNAPSHOT.war" "C:\apache-tomcat-10.1.x\webapps\logitrack.war"
```

### Paso 4: Iniciar Tomcat

**Windows:**
```cmd
cd C:\apache-tomcat-10.1.x\bin
startup.bat
```

O haz doble clic en `C:\apache-tomcat-10.1.x\bin\startup.bat`

### Paso 5: Verificar el Despliegue

1. **Espera 30-60 segundos** mientras Tomcat despliega la aplicación
2. **Verifica los logs** en: `C:\apache-tomcat-10.1.x\logs\catalina.out`
3. **Busca el mensaje**: `Deployment of web application archive ... has finished`

### Paso 6: Acceder a la Aplicación

Una vez desplegada:
- **Frontend**: http://localhost:8080/logitrack/
- **Swagger**: http://localhost:8080/logitrack/swagger-ui.html
- **API Login**: http://localhost:8080/logitrack/api/auth/login

---

## 🔑 Credenciales de Acceso

```
Usuario: demo
Contraseña: demo123
Rol: ADMIN
```

---

## 🗄️ Configuración de Base de Datos

La aplicación está configurada para conectarse a MySQL con:

```properties
URL: jdbc:mysql://localhost:3306/logitrack_db
Usuario: root
Password: campus2023
```

**Asegúrate de que MySQL esté corriendo** antes de iniciar la aplicación.

---

## 📊 Datos de Prueba Incluidos

La base de datos ya contiene:

✅ **Empresas**: 1 empresa demo
✅ **Usuarios**:
   - `demo/demo123` (ADMIN)
   - `juan/admin123` (EMPLEADO)

✅ **Bodegas**: 3 bodegas (Central, Norte, Sur)
✅ **Productos**: 4 productos (Laptop, Silla, Teclado, Escritorio)
✅ **Inventario**: Stock distribuido entre las 3 bodegas

---

## 🛠️ Solución de Problemas

### Problema 1: Puerto 8080 ya en uso

**Solución**: Cambia el puerto de Tomcat editando:
```
C:\apache-tomcat-10.1.x\conf\server.xml
```

Busca la línea:
```xml
<Connector port="8080" protocol="HTTP/1.1"
```

Cámbialo a otro puerto, por ejemplo `8090`.

### Problema 2: Error al conectar con MySQL

**Verifica que MySQL esté corriendo:**
```bash
mysql -u root -pcampus2023 -e "SHOW DATABASES;"
```

### Problema 3: La aplicación no despliega

**Revisa los logs:**
```
C:\apache-tomcat-10.1.x\logs\catalina.out
C:\apache-tomcat-10.1.x\logs\localhost.log
```

### Problema 4: Error 404 al acceder

**Verifica que el WAR se haya desplegado:**
```bash
dir C:\apache-tomcat-10.1.x\webapps\logitrack
```

Debe existir una carpeta `logitrack` con los archivos extraídos.

---

## 📝 Comandos Útiles de Tomcat

**Iniciar Tomcat:**
```cmd
C:\apache-tomcat-10.1.x\bin\startup.bat
```

**Detener Tomcat:**
```cmd
C:\apache-tomcat-10.1.x\bin\shutdown.bat
```

**Ver logs en tiempo real:**
```cmd
tail -f C:\apache-tomcat-10.1.x\logs\catalina.out
```

**Recargar aplicación sin reiniciar Tomcat:**
```
Elimina la carpeta: C:\apache-tomcat-10.1.x\webapps\logitrack
Elimina el archivo: C:\apache-tomcat-10.1.x\webapps\logitrack.war
Vuelve a copiar el WAR
```

---

## 🎯 Verificación Post-Despliegue

### 1. Verifica que Tomcat está corriendo:
```bash
netstat -ano | findstr :8080
```

### 2. Prueba el endpoint de login:
```bash
curl -X POST http://localhost:8080/logitrack/api/auth/login -H "Content-Type: application/json" -d "{\"username\":\"demo\",\"password\":\"demo123\"}"
```

Debe devolver un token JWT.

### 3. Accede al frontend:
```
http://localhost:8080/logitrack/
```

Debe mostrar la pantalla de login de LogiTrack.

---

## 📚 Estructura del Proyecto

```
logitrack/
├── WEB-INF/
│   ├── classes/           # Clases compiladas
│   ├── lib/              # Dependencias JAR
│   └── web.xml           # Descriptor (Spring Boot lo genera automático)
├── static/               # Frontend React
│   ├── index.html
│   ├── assets/
│   └── ...
└── META-INF/
```

---

## 🔐 Configuración de Seguridad para Producción

Antes de desplegar en producción, modifica `application.properties`:

```properties
# Cambiar credenciales de BD
spring.datasource.password=TU_PASSWORD_SEGURO

# Configurar secret JWT
# (Actualmente usa un secret por defecto)

# Deshabilitar Swagger en producción
springdoc.api-docs.enabled=false
springdoc.swagger-ui.enabled=false

# Configurar CORS si frontend está en otro dominio
# (Ya está configurado para permitir todas las origins)
```

---

## ✅ Checklist de Despliegue

- [ ] MySQL corriendo en localhost:3306
- [ ] Base de datos `logitrack_db` creada
- [ ] Tomcat descargado y extraído
- [ ] WAR copiado a `webapps/logitrack.war`
- [ ] Tomcat iniciado con `startup.bat`
- [ ] Logs revisados (sin errores)
- [ ] Frontend accesible en http://localhost:8080/logitrack/
- [ ] Login funcional con usuario `demo/demo123`

---

## 📞 Endpoints Principales

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/auth/login` | POST | Autenticación |
| `/api/auth/register` | POST | Registro empleado |
| `/api/auth/register-admin` | POST | Registro admin |
| `/api/productos` | GET | Listar productos |
| `/api/bodegas` | GET | Listar bodegas |
| `/api/movimientos` | GET/POST | Gestión movimientos |
| `/api/inventario` | GET | Consultar inventario |
| `/api/reportes/resumen` | GET | Dashboard resumen |
| `/api/auditoria` | GET | Historial auditoría |

**Documentación completa en**: http://localhost:8080/logitrack/swagger-ui.html

---

¡Aplicación lista para desplegar! 🚀
