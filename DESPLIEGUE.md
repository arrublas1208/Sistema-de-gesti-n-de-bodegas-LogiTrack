# 🚀 Guía de Despliegue - LogiTrack en Tomcat

## Despliegue Automático (Recomendado)

### Requisitos previos:
1. **Java 17+** instalado
2. **Maven** instalado
3. **Node.js y npm** instalados
4. **MySQL** corriendo en localhost:3306
5. **Apache Tomcat 9+** instalado
6. Variable de entorno `CATALINA_HOME` configurada

### Configurar CATALINA_HOME:
```bash
export CATALINA_HOME=/ruta/a/tu/tomcat
```

### Ejecutar despliegue:
```bash
./deploy-tomcat.sh
```

El script automáticamente:
- ✅ Construye el frontend
- ✅ Genera el archivo WAR
- ✅ Detiene Tomcat (si está corriendo)
- ✅ Limpia despliegues anteriores
- ✅ Despliega el nuevo WAR
- ✅ Inicia Tomcat

---

## Despliegue Manual

### Paso 1: Construir el frontend
```bash
cd frontend
npm install
npm run build
cd ..
```

### Paso 2: Generar el WAR
```bash
mvn clean package -DskipTests
```

### Paso 3: Copiar a Tomcat
```bash
cp target/logitrack-0.0.1-SNAPSHOT.war $CATALINA_HOME/webapps/logitrack.war
```

### Paso 4: Iniciar Tomcat
```bash
$CATALINA_HOME/bin/startup.sh
```

---

## Acceder a la Aplicación

Una vez desplegado, accede a:

- **Frontend**: http://localhost:8080/logitrack/
- **API REST**: http://localhost:8080/logitrack/api/
- **Documentación Swagger**: http://localhost:8080/logitrack/swagger-ui.html

---

## Verificar el Despliegue

### Ver logs de Tomcat:
```bash
tail -f $CATALINA_HOME/logs/catalina.out
```

### Buscar errores:
```bash
grep -i error $CATALINA_HOME/logs/catalina.out
```

---

## Base de Datos

La aplicación requiere MySQL corriendo con:

- **Host**: localhost
- **Puerto**: 3306
- **Base de datos**: logitrack_db
- **Usuario**: root
- **Password**: root

La base de datos se crea automáticamente si no existe.

---

## Detener la Aplicación

```bash
$CATALINA_HOME/bin/shutdown.sh
```

---

## Solución de Problemas

### Error: Puerto 8080 en uso
```bash
# Cambiar puerto en $CATALINA_HOME/conf/server.xml
# O matar el proceso usando el puerto:
lsof -ti:8080 | xargs kill -9
```

### Error: Base de datos no conecta
1. Verificar que MySQL esté corriendo:
   ```bash
   mysql -u root -p -e "SELECT 1"
   ```
2. Verificar credenciales en `src/main/resources/application.properties`

### Error: Java version incorrecta
```bash
java -version  # Debe ser Java 17+
```

---

## Regenerar WAR (desarrollo)

Si haces cambios en el código:

```bash
cd frontend && npm run build && cd ..
mvn clean package -DskipTests
```

---

## Configuración de Producción

Para producción, considera:

1. **Cambiar credenciales de BD**:
   - Editar `application.properties`
   - Usar variables de entorno

2. **Deshabilitar logs de debug**:
   ```properties
   logging.level.org.springframework=WARN
   logging.level.org.hibernate=WARN
   ```

3. **Configurar SSL/HTTPS** en Tomcat

4. **Aumentar heap de JVM**:
   ```bash
   export CATALINA_OPTS="-Xms512m -Xmx2048m"
   ```

---

## Archivos Modificados para WAR

✅ `pom.xml` - Configurado para packaging WAR
✅ `ServletInitializer.java` - Creado para Tomcat
✅ `application.properties` - Context-path configurado

**Nota**: La aplicación sigue funcionando como JAR standalone si es necesario.
