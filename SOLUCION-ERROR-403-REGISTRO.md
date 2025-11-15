# Solución Error 403 en Registro

## Problema Identificado

El botón "Crear cuenta (Admin)" en la página de login daba error **403 Forbidden**.

### Causa Raíz

Había un **conflicto de configuración** en `SecurityConfig.java`:

- **Línea 38 (ANTES)**:
  ```java
  .requestMatchers(HttpMethod.POST, "/api/auth/register-admin").hasRole("ADMIN")
  ```

  Esto requería que el usuario **YA estuviera autenticado como ADMIN** para poder registrarse.

- **Pero**: El botón "Crear cuenta" está en la página de **LOGIN** (antes de autenticarse).

- **Resultado**: Error 403 porque no hay token JWT válido.

## Solución Aplicada

Cambié `SecurityConfig.java` línea 39 para permitir registro público:

```java
.requestMatchers(HttpMethod.POST, "/api/auth/register-admin").permitAll()
```

### Archivos Modificados

1. `src/main/java/com/logitrack/security/SecurityConfig.java`
   - Línea 39: Cambió de `.hasRole("ADMIN")` a `.permitAll()`

## Cómo Desplegar

Ejecuta el script de despliegue:

```bash
./desplegar-con-registro-arreglado.sh
```

Este script:
1. Detiene Tomcat
2. Elimina el WAR antiguo
3. Copia el nuevo WAR
4. Reinicia Tomcat

## Cómo Usar el Registro

### Opción 1: Crear Admin desde Login (NUEVO - Ahora funciona)

1. Ve a http://localhost:8080/logitrack/
2. Haz clic en **"Crear cuenta (Admin)"**
3. Llena el formulario:
   - Usuario
   - Nombre completo
   - Email
   - Cédula
   - Contraseña
4. ✅ Ya NO dará error 403

### Opción 2: Crear Empleados desde dentro de la App (Recomendado)

1. Inicia sesión con: `admin` / `admin123`
2. En el sidebar, haz clic en **"Usuarios"** (solo visible para ADMIN)
3. Crea empleados desde ahí
4. ✅ Más seguro porque requiere autenticación

## ⚠️ Advertencia de Seguridad

**Permitir registro público de admins es INSEGURO en producción.**

En un ambiente de producción real, deberías:

1. **Desactivar** el registro público de admins
2. **Crear el primer admin** manualmente en la base de datos
3. **Crear usuarios adicionales** desde dentro de la app (autenticados)

### Para desactivar en producción:

Cambia `SecurityConfig.java` línea 39 de vuelta a:

```java
.requestMatchers(HttpMethod.POST, "/api/auth/register-admin").hasRole("ADMIN")
```

Y elimina el botón "Crear cuenta (Admin)" del frontend.

## Credenciales Existentes

Ya existe un admin creado:

- **Usuario**: `admin`
- **Contraseña**: `admin123`

También existe:

- **Usuario**: `juan`
- **Contraseña**: `admin123`
- **Rol**: EMPLEADO

## Verificar que Funciona

Después de desplegar:

1. Abre: http://localhost:8080/logitrack/
2. Haz clic en "Crear cuenta (Admin)"
3. Llena el formulario
4. Debería crear el usuario **sin error 403**
5. Luego podrás iniciar sesión con ese usuario

## Resumen de Cambios

| Archivo | Línea | Cambio | Razón |
|---------|-------|--------|-------|
| `SecurityConfig.java` | 39 | `.hasRole("ADMIN")` → `.permitAll()` | Permitir registro público de admin |

## Logs

Para monitorear si hay errores:

```bash
sudo tail -f /opt/tomcat/logs/catalina.out
```

Busca mensajes como:
- ✅ "Started ServletInitializer" - Aplicación arrancó bien
- ❌ "403" - Aún hay problemas de autorización
- ❌ "Bad credentials" - Contraseña incorrecta
