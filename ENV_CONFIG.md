# Configuración de Variables de Entorno - LogiTrack

Este documento describe las variables de entorno necesarias para desplegar LogiTrack en producción.

## Variables Críticas de Seguridad

### Base de Datos

```bash
# URL de conexión a MySQL
DB_URL=jdbc:mysql://localhost:3306/logitrack_db?useSSL=true&serverTimezone=UTC

# Usuario de base de datos
DB_USERNAME=logitrack_user

# Contraseña de base de datos (¡NUNCA usar valores por defecto!)
DB_PASSWORD=TU_CONTRASEÑA_SEGURA_AQUI
```

### JWT (JSON Web Token)

```bash
# Secreto JWT - CRÍTICO: Debe ser una clave aleatoria de 256+ bits
# Generar con: openssl rand -base64 64
JWT_SECRET=TU_CLAVE_JWT_SUPER_SECRETA_DE_AL_MENOS_256_BITS_AQUI

# Tiempo de validez del token en milisegundos (por defecto: 1 hora)
JWT_VALIDITY_MS=3600000
```

**Ejemplo de generación de JWT_SECRET:**
```bash
openssl rand -base64 64
```

### CORS (Cross-Origin Resource Sharing)

```bash
# Orígenes permitidos separados por coma (dominios específicos de tu aplicación)
CORS_ALLOWED_ORIGINS=https://app.logitrack.com,https://admin.logitrack.com
```

**IMPORTANTE:** En producción, NUNCA usar `*` o `http://localhost`. Solo dominios específicos de tu aplicación.

## Variables Opcionales

### Puerto del Servidor

```bash
# Puerto en el que correrá la aplicación (por defecto: 8081)
PORT=8080
```

## Configuración en Diferentes Entornos

### Desarrollo Local

Crear archivo `.env` en la raíz del proyecto (NO commitear):

```bash
DB_URL=jdbc:mysql://localhost:3306/logitrack_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&createDatabaseIfNotExist=true
DB_USERNAME=root
DB_PASSWORD=campus2023
JWT_SECRET=dev-secret-key-only-for-local-development-change-in-production
JWT_VALIDITY_MS=3600000
CORS_ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000,http://localhost:8081
PORT=8081
```

### Producción en Tomcat

**Opción 1: Variables de entorno del sistema (Linux/Unix)**

Editar archivo `/etc/environment` o `~/.bashrc`:

```bash
export DB_URL="jdbc:mysql://mysql-server:3306/logitrack_db?useSSL=true&serverTimezone=UTC"
export DB_USERNAME="logitrack_prod_user"
export DB_PASSWORD="CONTRASEÑA_SUPER_SEGURA_AQUI"
export JWT_SECRET="CLAVE_JWT_GENERADA_CON_OPENSSL_RAND_BASE64_64"
export JWT_VALIDITY_MS="3600000"
export CORS_ALLOWED_ORIGINS="https://app.logitrack.com"
export PORT="8080"
```

**Opción 2: Configuración de Tomcat**

Editar archivo `$CATALINA_HOME/bin/setenv.sh` (crear si no existe):

```bash
#!/bin/bash
export DB_URL="jdbc:mysql://mysql-server:3306/logitrack_db?useSSL=true&serverTimezone=UTC"
export DB_USERNAME="logitrack_prod_user"
export DB_PASSWORD="CONTRASEÑA_SUPER_SEGURA_AQUI"
export JWT_SECRET="CLAVE_JWT_GENERADA_CON_OPENSSL_RAND_BASE64_64"
export JWT_VALIDITY_MS="3600000"
export CORS_ALLOWED_ORIGINS="https://app.logitrack.com"
export PORT="8080"
```

En Windows (`setenv.bat`):

```batch
set DB_URL=jdbc:mysql://mysql-server:3306/logitrack_db?useSSL=true^&serverTimezone=UTC
set DB_USERNAME=logitrack_prod_user
set DB_PASSWORD=CONTRASEÑA_SUPER_SEGURA_AQUI
set JWT_SECRET=CLAVE_JWT_GENERADA_AQUI
set JWT_VALIDITY_MS=3600000
set CORS_ALLOWED_ORIGINS=https://app.logitrack.com
set PORT=8080
```

**Opción 3: Context.xml de Tomcat**

Editar `$CATALINA_HOME/conf/context.xml`:

```xml
<Context>
    <Environment name="DB_URL" value="jdbc:mysql://mysql-server:3306/logitrack_db?useSSL=true&amp;serverTimezone=UTC" type="java.lang.String" override="false"/>
    <Environment name="DB_USERNAME" value="logitrack_prod_user" type="java.lang.String" override="false"/>
    <Environment name="DB_PASSWORD" value="CONTRASEÑA_SUPER_SEGURA_AQUI" type="java.lang.String" override="false"/>
    <Environment name="JWT_SECRET" value="CLAVE_JWT_GENERADA_AQUI" type="java.lang.String" override="false"/>
    <Environment name="JWT_VALIDITY_MS" value="3600000" type="java.lang.String" override="false"/>
    <Environment name="CORS_ALLOWED_ORIGINS" value="https://app.logitrack.com" type="java.lang.String" override="false"/>
    <Environment name="PORT" value="8080" type="java.lang.String" override="false"/>
</Context>
```

## Checklist de Seguridad Pre-Despliegue

Antes de desplegar en producción, verificar:

- [ ] `DB_PASSWORD` es diferente al valor por defecto
- [ ] `JWT_SECRET` es una clave aleatoria de 256+ bits (NO usar el valor por defecto)
- [ ] `CORS_ALLOWED_ORIGINS` contiene SOLO dominios específicos (NO `*`, NO `http://localhost`)
- [ ] `DB_URL` usa `useSSL=true` en producción
- [ ] Las credenciales NO están hardcodeadas en el código
- [ ] El archivo `.env` está en `.gitignore`
- [ ] Las variables de entorno están configuradas en el servidor de producción
- [ ] Se ha verificado que Tomcat puede leer las variables de entorno

## Verificación

Para verificar que las variables de entorno están configuradas correctamente:

**Linux/Mac:**
```bash
echo $DB_URL
echo $JWT_SECRET
echo $CORS_ALLOWED_ORIGINS
```

**Windows:**
```cmd
echo %DB_URL%
echo %JWT_SECRET%
echo %CORS_ALLOWED_ORIGINS%
```

**En la aplicación Spring Boot:**

Agregar temporalmente en el método `main` de `LogitrackApplication.java`:

```java
@PostConstruct
public void checkEnv() {
    System.out.println("DB_URL: " + (System.getenv("DB_URL") != null ? "Configurado ✓" : "NO configurado ✗"));
    System.out.println("DB_USERNAME: " + (System.getenv("DB_USERNAME") != null ? "Configurado ✓" : "NO configurado ✗"));
    System.out.println("DB_PASSWORD: " + (System.getenv("DB_PASSWORD") != null ? "Configurado ✓" : "NO configurado ✗"));
    System.out.println("JWT_SECRET: " + (System.getenv("JWT_SECRET") != null ? "Configurado ✓" : "NO configurado ✗"));
    System.out.println("CORS_ALLOWED_ORIGINS: " + (System.getenv("CORS_ALLOWED_ORIGINS") != null ? "Configurado ✓" : "NO configurado ✗"));
}
```

## Problemas Comunes

### 1. Variables no reconocidas en Tomcat

**Solución:** Reiniciar completamente el servicio Tomcat:

```bash
# Linux
sudo systemctl restart tomcat

# Windows
net stop tomcat
net start tomcat
```

### 2. Context.xml no funciona

**Solución:** Asegurarse de que la aplicación accede las variables con:

```java
System.getenv("VARIABLE_NAME")
// O con @Value en Spring:
@Value("${VARIABLE_NAME}")
```

### 3. Valores por defecto siendo usados

**Solución:** Verificar que las variables estén definidas ANTES de iniciar Tomcat. Spring Boot usará los valores por defecto si no encuentra las variables de entorno.

## Soporte

Para más información sobre configuración de variables de entorno en Spring Boot:
- https://docs.spring.io/spring-boot/docs/current/reference/html/application-properties.html
- https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config
