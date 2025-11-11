# Despliegue en Tomcat – LogiTrack

Guía para empaquetar y desplegar el backend (con frontend estático) en Apache Tomcat.

## Prerrequisitos
- Tomcat 9/10 instalado.
- JDK compatible.
- Base de datos accesible desde el servidor.

## Empaquetado WAR
- Cambiar `pom.xml` a `packaging=war`.
- Usar `spring-boot-starter-tomcat` con `scope=provided`.
- Añadir `SpringBootServletInitializer` para inicializar como WAR.

### Ejemplo `pom.xml` (fragmento)
```xml
<packaging>war</packaging>
<dependencies>
  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-tomcat</artifactId>
    <scope>provided</scope>
  </dependency>
  <!-- resto de dependencias -->
 </dependencies>
```

### Inicializador
```java
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

public class ServletInitializer extends SpringBootServletInitializer {
  @Override
  protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
    return application.sources(YourSpringBootApplication.class);
  }
}
```

## Context Path
- Configurar `server.servlet.context-path=/logitrack` (opcional) en `application.properties`.
- Las rutas quedarían `http://host:port/logitrack/api/...`.

## Frontend estático
- Generar el bundle con Vite:
  - `cd frontend && npm install && npm run build`
- Verificar que los archivos se ubiquen en `src/main/resources/static/` para que se empaqueten dentro del WAR.

## Build y despliegue
- `mvn clean package` → genera `logitrack.war` en `target/`.
- Copiar el WAR a `TOMCAT_HOME/webapps/`.
- Iniciar Tomcat y validar:
  - `http://host:port/` (o `http://host:port/logitrack/` si se definió `context-path`).
  - `http://host:port/logitrack/api/...` responde.
  - UI carga y consume `/api` en el mismo origen.

## Configuración externalizada
- Variables sensibles (DB, JWT secret, CORS) fuera del WAR.
- Usar propiedades en `CATALINA_BASE/conf` o variables de entorno.

## Logs y health checks
- Revisar `catalina.out` y logs configurados.
- Activar Actuator `GET /actuator/health` para monitoreo básico.

## Troubleshooting
- 404 de assets: verificar que Vite haya publicado a `static/` antes de `mvn package`.
- 403/CORS: ajustar orígenes y métodos permitidos.
- 500 al iniciar: revisar dependencias con `provided` y errores de inicialización.
- Rutas rotas con `context-path`: confirmar que la UI usa `window.location.origin + "/api"`.

## CI/CD sugerido
- Pipeline: build frontend → publicar en `static` → `mvn test` → escaneo seguridad → `mvn package` → despliegue WAR → smoke tests.