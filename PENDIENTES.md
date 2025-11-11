# Lista de Pendientes (Backlog) – LogiTrack

Esta lista consolida los trabajos pendientes para dejar el proyecto al 100% en backend, frontend, seguridad y despliegue en Tomcat.

## Backend
- Uniformar contratos en `/api/movimientos`: usar `usuarioId` y estabilizar `usuario` (objeto/cadena).
- Implementar paginación y ordenamiento en `movimientos`, `inventario`, `auditoria` y `productos`.
- Añadir filtros server-side (fecha, tipo, bodega, usuario, categoría) en endpoints relevantes.
- Estandarizar formato de errores: `{"message":"...","details":{"message":"..."}}`.
- Validaciones de negocio adicionales: capacidad de bodega, stock mínimo, movimientos coherentes (origen/destino).
- Normalizar DTOs y mapeo entity↔DTO; evitar exponer entidades directamente en controladores.
- Optimizar consultas: evitar N+1, agregar índices en campos usados en filtros y ordenamiento.
- Migraciones de base de datos con Flyway/Liquibase; documentar cambios de esquema.
- Tests unitarios (servicios) e integración (controladores/repositorios) con datos semilla.
- Mejorar Swagger/OpenAPI: ejemplos, respuestas de error, tags y agrupación por módulos.
- Auditoría ampliada: incluir rol/usuario, paginación, y endpoint de consulta avanzada.
- Configuración externalizada (`application.properties`/`application.yml`); perfiles `dev`/`prod`.
- CORS para desarrollo controlado; permitir el origen de `vite dev` si se usa servidor separado.

## Frontend
- Estados de carga y error consistentes en todas las vistas.
- Paginación, ordenamiento y filtros en UI para listas largas.
- Formularios de movimientos con validación de campos y mensajes claros.
- Gestión de estado: revisar `Context` y hooks para evitar renders innecesarios.
- Uso consistente de `api()` con manejo de tiempo de espera y errores; mejorar mensajes.
- Accesibilidad: semántica, foco, navegación por teclado y contrastes.
- i18n básica (ES) y preparación para agregar otros idiomas.
- Tests con Vitest/React Testing Library (render, llamadas a API simuladas).
- Performance: memoización, virtualización de listas si aplica, evitar re-render costoso.
- Reemplazar íconos CDN por assets locales; empaquetar con Vite.
- Manejo de `null/undefined` en datos de API; proteger render y formato.

## Seguridad
- Autenticación (JWT o sesión): endpoints de login/logout y protección de `/api/**`.
- Autorización por rol (ADMIN, OPERADOR): restricciones en creación/edición de movimientos e inventario.
- Configurar Spring Security; deshabilitar endpoints no necesarios y proteger documentos Swagger en producción.
- CSRF (según modalidad), CORS seguro (orígenes permitidos y métodos), cookies con `HttpOnly/SameSite`.
- Validación de entrada con Bean Validation; sanitización y prevención de inyección.
- Cabeceras de seguridad: HSTS, `X-Content-Type-Options`, `X-Frame-Options`, `Content-Security-Policy` ajustada.
- Rate limiting para endpoints críticos (movimientos, login).
- Logging y alertas de seguridad; trazabilidad completa en auditoría.
- Gestión de secretos: externalizar credenciales (variables de entorno, `.env`), evitar en repositorio.
- Tokens: expiración, refresco, revocación y lista de bloqueo; cambio de contraseña seguro.
- Escaneo de dependencias y vulnerabilidades (OWASP Dependency-Check/Snyk) y actualización regular.

## Despliegue en Tomcat
- Cambiar `pom.xml` a `packaging=war`; `spring-boot-starter-tomcat` como `provided`.
- Añadir `SpringBootServletInitializer` para inicializar la aplicación como WAR.
- Definir `server.servlet.context-path` (por ejemplo, `/logitrack`).
- Garantizar que el bundle Vite (`src/main/resources/static`) se incluya y sirva dentro del WAR.
- Externalizar configuración (`DB`, `CORS`, `security`) mediante propiedades del servidor.
- Script de build: `mvn clean package` para generar `logitrack.war`.
- Instrucciones de despliegue: copiar WAR a `tomcat/webapps/`, validar rutas `/api` y assets.
- Logs en Tomcat (`catalina.out`) y configuración de rotación.
- Health checks con Actuator (`/actuator/health`) y verificación de readiness.
- Pipeline CI/CD (build, tests, seguridad, empaquetado WAR, despliegue) y rollback.

## Criterios de Terminado
- Sin errores en consola (navegador y servidor) y UI estable.
- Endpoints con paginación, filtros y contratos sólidos; Swagger actualizado.
- Seguridad aplicada y validada (auth/roles, cabeceras, CORS, CSRF si corresponde).
- Build reproducible: `npm run build` publica estáticos y `mvn package` genera WAR listo para Tomcat.
- Documentación actualizada (`README.md`, `INVENTARIO_API.md`, `MOVIMIENTOS_API.md`, `POSTMAN_TESTS.md`).

## Referencias
- `README.md` → Estado del frontend y guía de build.
- `INVENTARIO_API.md`, `MOVIMIENTOS_API.md`, `POSTMAN_TESTS.md` → contratos y pruebas.