# Guía de Seguridad – LogiTrack

Este documento define políticas, arquitectura y criterios de seguridad para el sistema.

## Autenticación
- Mecanismo sugerido: JWT (stateless) sobre HTTPS.
- Endpoints:
  - `POST /api/auth/login` → `{ username, password }` → `{ accessToken, refreshToken, usuario: { id, nombre, rol } }`
  - `POST /api/auth/refresh` → `{ refreshToken }` → `{ accessToken }`
  - `POST /api/auth/logout` → invalida el refresh token (lista de bloqueo).
- JWT:
  - Contiene `sub`, `roles`, `exp`.
  - Short-lived para `accessToken`; `refreshToken` con mayor duración.

## Autorización
- Roles sugeridos: `ADMIN`, `OPERADOR`.
- Matriz (ejemplo):
  - `ADMIN`: CRUD completo en bodegas/productos/inventario/movimientos; acceso a reportes y auditoría.
  - `OPERADOR`: crear movimientos, consultar inventario y productos; acceso limitado a reportes.
- Aplicar restricciones por endpoint en controladores/servicios.

## Spring Security (líneas generales)
- Configurar filtro JWT y `SecurityFilterChain`.
- Proteger `/api/**` y permitir `/swagger-ui/**` solo en `dev`.
- Deshabilitar CSRF si JWT (stateless). Si no, usar tokens CSRF.
- Configurar CORS: orígenes permitidos, métodos, cabeceras.

## CORS
- Desarrollo: permitir el origen de `vite dev` si aplica.
- Producción: restringir a dominios específicos.
- Cabeceras: `Access-Control-Allow-Origin`, `Access-Control-Allow-Credentials` (según cookies), etc.

## Cabeceras de seguridad
- HSTS.
- `X-Content-Type-Options: nosniff`.
- `X-Frame-Options: DENY`.
- `Referrer-Policy: no-referrer`.
- `Content-Security-Policy` (CSP):
  - `default-src 'self'`.
  - `script-src 'self'` (evitar `unsafe-inline`).
  - `style-src 'self'` (o permitir hashes si aplica).
  - `img-src 'self' data:`.
  - `font-src 'self'`.
  - `connect-src 'self'`.

## Validación y sanitización
- Bean Validation en DTOs (`@NotNull`, `@Size`, etc.).
- Sanitizar entradas de texto y evitar inyecciones.
- Serialización segura; no exponer entidades directamente.

## Rate limiting
- Limitar intentos de login y operaciones críticas (creación de movimientos).
- Implementación sugerida: filtro con bucket tokens o librería compatible.

## Logging y auditoría
- Registrar operaciones sensibles con usuario/rol/fecha.
- Alertas en intentos fallidos de autenticación.
- Mantener trazabilidad para inspección.

## Gestión de secretos
- No almacenar credenciales en el repositorio.
- Externalizar variables (BD, JWT secret, etc.).
- Rotación periódica y protección de acceso.

## Dependencias y vulnerabilidades
- Escaneo regular (OWASP Dependency-Check, Snyk).
- Actualizaciones de seguridad y monitoreo de CVEs.

## Criterios de aceptación
- Endpoints protegidos por JWT.
- Roles aplicados correctamente con restricciones por endpoint.
- Cabeceras de seguridad activas; CORS configurado.
- Validaciones aplicadas; logs y auditoría operativos.
- Sin vulnerabilidades críticas detectadas en escaneos.