# Instrucciones de Login - LogiTrack

## 🔐 Credenciales de Acceso

### Usuario Administrador (ya creado)
```
Username: admin
Password: admin123
```

### Usuario Empleado (para pruebas)
```
Username: juan
Password: admin123
```

---

## ⚠️ Error 403 al Registrarse

Si ves el error:
```
POST http://localhost:8081/api/auth/register-admin 403 (Forbidden)
```

**Esto es NORMAL y esperado** por las mejoras de seguridad implementadas.

### ¿Por qué ocurre?

Por seguridad, el endpoint de registro de administradores ahora **requiere autenticación de ADMIN**. Esto previene que cualquier persona pueda crear cuentas de administrador sin autorización.

### Solución

**No necesitas registrarte**, ya existe un usuario administrador creado en la base de datos:

1. En la pantalla de login, ingresa:
   - Username: `admin`
   - Password: `admin123`

2. Click en "Iniciar Sesión"

3. Tendrás acceso completo a todas las funcionalidades

---

## 👥 Crear Nuevos Usuarios

Una vez autenticado como `admin`, puedes crear nuevos usuarios desde:

1. **Opción 1: Desde la aplicación**
   - Ir a la sección "Usuarios"
   - Click en "Nuevo Usuario"
   - Completar el formulario
   - La aplicación enviará automáticamente tu token de autenticación

2. **Opción 2: Usando Swagger UI**
   - Ir a: http://localhost:8081/swagger-ui/index.html
   - Hacer login en `/api/auth/login`
   - Copiar el `accessToken` de la respuesta
   - Click en "Authorize" (botón con candado)
   - Pegar: `Bearer <tu-token>`
   - Ahora puedes usar `/api/auth/register` o `/api/auth/register-admin`

---

## 🔓 Si Necesitas Abrir el Registro (No Recomendado)

Si REALMENTE necesitas permitir el registro sin autenticación (solo para desarrollo/testing), puedes:

1. Detener la aplicación (Ctrl+C)

2. Editar el archivo: `src/main/java/com/logitrack/security/SecurityConfig.java`

3. Cambiar la línea 38:
   ```java
   // ANTES (Seguro)
   .requestMatchers(HttpMethod.POST, "/api/auth/register-admin").hasRole("ADMIN")

   // DESPUÉS (Inseguro - solo para desarrollo)
   .requestMatchers(HttpMethod.POST, "/api/auth/register-admin").permitAll()
   ```

4. Recompilar y reiniciar:
   ```bash
   ./mvnw.cmd clean package -DskipTests
   java -jar target/logitrack-0.0.1-SNAPSHOT.war
   ```

**⚠️ ADVERTENCIA:** Esto elimina la protección de seguridad. Solo hazlo en ambiente de desarrollo local, NUNCA en producción.

---

## 📞 Soporte

Si tienes problemas para iniciar sesión:
- Verifica que MySQL esté corriendo
- Verifica que la aplicación esté corriendo en http://localhost:8081
- Verifica que uses exactamente: `admin` / `admin123` (case-sensitive)
- Revisa los logs de la aplicación en la consola

---

**¡Usa las credenciales existentes para iniciar sesión!** 🚀
