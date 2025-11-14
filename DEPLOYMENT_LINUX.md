# Guía de Despliegue - LogiTrack en Linux con Tomcat 10.0.20

## Tabla de Contenidos
1. [Requisitos Previos](#requisitos-previos)
2. [Configuración de MySQL](#configuración-de-mysql)
3. [Instalación de Java 17](#instalación-de-java-17)
4. [Instalación de Tomcat 10.0.20](#instalación-de-tomcat-1000)
5. [Compilación del Proyecto](#compilación-del-proyecto)
6. [Despliegue en Tomcat](#despliegue-en-tomcat)
7. [Verificación del Despliegue](#verificación-del-despliegue)
8. [Troubleshooting](#troubleshooting)

---

## Requisitos Previos

### Versiones Compatibles
- **Java**: JDK 17
- **Tomcat**: 10.0.20
- **Spring Boot**: 3.4.0
- **MySQL**: 8.0 o superior
- **Maven**: 3.6.3 o superior

---

## Configuración de MySQL

### 1. Instalar MySQL (si no está instalado)

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install mysql-server -y
```

**CentOS/RHEL/Rocky Linux:**
```bash
sudo dnf install mysql-server -y
sudo systemctl start mysqld
sudo systemctl enable mysqld
```

### 2. Configurar MySQL

Iniciar sesión en MySQL como root:
```bash
sudo mysql -u root -p
```

### 3. Crear usuario y base de datos

Ejecutar los siguientes comandos SQL:
```sql
-- Crear usuario campus2023
CREATE USER 'campus2023'@'localhost' IDENTIFIED BY 'campus2023';

-- Crear base de datos
CREATE DATABASE logitrack_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Otorgar privilegios
GRANT ALL PRIVILEGES ON logitrack_db.* TO 'campus2023'@'localhost';
FLUSH PRIVILEGES;

-- Verificar
SELECT user, host FROM mysql.user WHERE user='campus2023';
SHOW DATABASES;

-- Salir
EXIT;
```

### 4. Verificar conexión

```bash
mysql -u campus2023 -p
# Ingresar contraseña: campus2023
```

Si conecta exitosamente, la configuración de MySQL está completa.

---

## Instalación de Java 17

### Ubuntu/Debian:
```bash
# Instalar OpenJDK 17
sudo apt update
sudo apt install openjdk-17-jdk -y

# Verificar instalación
java -version
javac -version
```

### CentOS/RHEL/Rocky Linux:
```bash
# Instalar OpenJDK 17
sudo dnf install java-17-openjdk java-17-openjdk-devel -y

# Verificar instalación
java -version
javac -version
```

### Configurar JAVA_HOME:
```bash
# Encontrar ruta de Java
sudo update-alternatives --config java

# Editar .bashrc o .bash_profile
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Verificar
echo $JAVA_HOME
```

---

## Instalación de Tomcat 10.0.20

### 1. Descargar Tomcat 10.0.20

```bash
# Ir al directorio temporal
cd /tmp

# Descargar Tomcat 10.0.20
wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.0.20/bin/apache-tomcat-10.0.20.tar.gz

# Verificar descarga
ls -lh apache-tomcat-10.0.20.tar.gz
```

### 2. Instalar Tomcat

```bash
# Crear directorio para Tomcat
sudo mkdir -p /opt/tomcat

# Extraer Tomcat
sudo tar -xzf apache-tomcat-10.0.20.tar.gz -C /opt/tomcat --strip-components=1

# Verificar extracción
ls -l /opt/tomcat
```

### 3. Crear usuario para Tomcat

```bash
# Crear grupo y usuario tomcat
sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

# Dar permisos
sudo chown -R tomcat:tomcat /opt/tomcat
sudo chmod -R u+x /opt/tomcat/bin
```

### 4. Configurar Tomcat como servicio systemd

Crear archivo de servicio:
```bash
sudo nano /etc/systemd/system/tomcat.service
```

Pegar el siguiente contenido:
```ini
[Unit]
Description=Apache Tomcat 10.0.20
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
```

Guardar (Ctrl+O, Enter, Ctrl+X).

### 5. Configurar usuarios de Tomcat Manager (opcional)

```bash
sudo nano /opt/tomcat/conf/tomcat-users.xml
```

Antes de `</tomcat-users>`, agregar:
```xml
<role rolename="manager-gui"/>
<role rolename="admin-gui"/>
<user username="admin" password="admin123" roles="manager-gui,admin-gui"/>
```

### 6. Habilitar acceso remoto a Manager (opcional)

```bash
sudo nano /opt/tomcat/webapps/manager/META-INF/context.xml
```

Comentar la restricción de IP:
```xml
<!--
<Valve className="org.apache.catalina.valves.RemoteAddrValve"
       allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />
-->
```

### 7. Iniciar Tomcat

```bash
# Recargar systemd
sudo systemctl daemon-reload

# Iniciar Tomcat
sudo systemctl start tomcat

# Verificar estado
sudo systemctl status tomcat

# Habilitar inicio automático
sudo systemctl enable tomcat
```

### 8. Verificar Tomcat

```bash
# Ver logs en tiempo real
sudo tail -f /opt/tomcat/logs/catalina.out

# O abrir en navegador
curl http://localhost:8080
```

---

## Compilación del Proyecto

### 1. Instalar Maven (si no está instalado)

**Ubuntu/Debian:**
```bash
sudo apt install maven -y
mvn -version
```

**CentOS/RHEL:**
```bash
sudo dnf install maven -y
mvn -version
```

### 2. Clonar o copiar el proyecto

```bash
# Si está en repositorio Git
git clone <url-repositorio>
cd Sistema-de-gesti-n-de-bodegas-LogiTrack

# O si lo copiaste manualmente
cd /ruta/al/proyecto
```

### 3. Verificar configuración

Verificar que `application.properties` tenga las credenciales correctas:
```bash
cat src/main/resources/application.properties | grep datasource
```

Debe mostrar:
```
spring.datasource.username=${DB_USERNAME:campus2023}
spring.datasource.password=${DB_PASSWORD:campus2023}
```

### 4. Compilar el proyecto

```bash
# Limpiar compilaciones anteriores
mvn clean

# Compilar y generar WAR (sin tests)
mvn clean package -DskipTests

# O con tests (si están configurados)
mvn clean package
```

### 5. Verificar generación del WAR

```bash
ls -lh target/logitrack.war
```

Debe mostrar el archivo `logitrack.war` con tamaño aproximado de 50-80 MB.

---

## Despliegue en Tomcat

### Método 1: Despliegue Manual

```bash
# Detener Tomcat
sudo systemctl stop tomcat

# Eliminar despliegue anterior (si existe)
sudo rm -rf /opt/tomcat/webapps/logitrack
sudo rm -f /opt/tomcat/webapps/logitrack.war

# Copiar nuevo WAR
sudo cp target/logitrack.war /opt/tomcat/webapps/

# Dar permisos
sudo chown tomcat:tomcat /opt/tomcat/webapps/logitrack.war

# Iniciar Tomcat
sudo systemctl start tomcat

# Ver logs de despliegue
sudo tail -f /opt/tomcat/logs/catalina.out
```

### Método 2: Despliegue con Manager (si configuraste usuario)

```bash
# Usar curl para desplegar
curl -u admin:admin123 \
  --upload-file target/logitrack.war \
  "http://localhost:8080/manager/text/deploy?path=/logitrack&update=true"
```

### Método 3: Hot Deploy (sin detener Tomcat)

```bash
# Solo copiar el WAR
sudo cp target/logitrack.war /opt/tomcat/webapps/
sudo chown tomcat:tomcat /opt/tomcat/webapps/logitrack.war

# Tomcat detectará y desplegará automáticamente
sudo tail -f /opt/tomcat/logs/catalina.out
```

---

## Verificación del Despliegue

### 1. Verificar que la aplicación inició

```bash
# Ver logs
sudo tail -100 /opt/tomcat/logs/catalina.out

# Buscar mensaje de inicio exitoso
sudo grep "Started LogitrackApplication" /opt/tomcat/logs/catalina.out
```

### 2. Verificar directorio desplegado

```bash
ls -l /opt/tomcat/webapps/
# Debe mostrar:
# - logitrack/         (directorio)
# - logitrack.war      (archivo)
```

### 3. Probar endpoints

```bash
# Endpoint de salud (si existe)
curl http://localhost:8080/logitrack/api/health

# Swagger UI
curl http://localhost:8080/logitrack/swagger-ui.html

# O abrir en navegador:
# http://<ip-servidor>:8080/logitrack/swagger-ui.html
```

### 4. Verificar conexión a MySQL

```bash
# Ver logs de JPA/Hibernate
sudo grep -i "HikariPool" /opt/tomcat/logs/catalina.out
sudo grep -i "mysql" /opt/tomcat/logs/catalina.out
```

---

## Troubleshooting

### Problema 1: Tomcat no inicia

**Síntomas:**
```bash
sudo systemctl status tomcat
# Estado: failed
```

**Soluciones:**
```bash
# Verificar JAVA_HOME
echo $JAVA_HOME
java -version

# Ver logs de error
sudo journalctl -u tomcat -n 50

# Verificar permisos
ls -la /opt/tomcat/bin/

# Dar permisos de ejecución
sudo chmod -R u+x /opt/tomcat/bin
```

### Problema 2: WAR no se despliega

**Síntomas:**
- No se crea directorio `/opt/tomcat/webapps/logitrack/`

**Soluciones:**
```bash
# Ver logs de Tomcat
sudo tail -200 /opt/tomcat/logs/catalina.out

# Verificar permisos del WAR
ls -l /opt/tomcat/webapps/logitrack.war
sudo chown tomcat:tomcat /opt/tomcat/webapps/logitrack.war

# Forzar redespliegue
sudo systemctl restart tomcat
```

### Problema 3: Error de conexión a MySQL

**Síntomas:**
```
Could not create connection to database server
Access denied for user 'campus2023'@'localhost'
```

**Soluciones:**
```bash
# Verificar que MySQL esté corriendo
sudo systemctl status mysql

# Verificar usuario y permisos
mysql -u campus2023 -p
# Ingresar: campus2023

# Si no conecta, recrear usuario
sudo mysql -u root -p
```

```sql
DROP USER IF EXISTS 'campus2023'@'localhost';
CREATE USER 'campus2023'@'localhost' IDENTIFIED BY 'campus2023';
GRANT ALL PRIVILEGES ON logitrack_db.* TO 'campus2023'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Problema 4: Puerto 8080 en uso

**Soluciones:**
```bash
# Ver qué proceso usa el puerto
sudo netstat -tulpn | grep 8080
sudo lsof -i :8080

# Cambiar puerto de Tomcat
sudo nano /opt/tomcat/conf/server.xml
# Buscar: <Connector port="8080"
# Cambiar a: <Connector port="8090"

# Reiniciar Tomcat
sudo systemctl restart tomcat
```

### Problema 5: OutOfMemoryError

**Síntomas:**
```
java.lang.OutOfMemoryError: Java heap space
```

**Soluciones:**
```bash
# Editar servicio de Tomcat
sudo nano /etc/systemd/system/tomcat.service

# Modificar CATALINA_OPTS:
Environment="CATALINA_OPTS=-Xms1024M -Xmx2048M -server -XX:+UseParallelGC"

# Recargar y reiniciar
sudo systemctl daemon-reload
sudo systemctl restart tomcat
```

### Problema 6: Context path incorrecto

**Síntomas:**
- La aplicación responde en `/` en lugar de `/logitrack`

**Soluciones:**

Opción A - Renombrar WAR a ROOT:
```bash
sudo systemctl stop tomcat
sudo rm -rf /opt/tomcat/webapps/ROOT
sudo mv /opt/tomcat/webapps/logitrack.war /opt/tomcat/webapps/ROOT.war
sudo systemctl start tomcat
```

Opción B - Crear archivo context.xml:
```bash
sudo nano /opt/tomcat/conf/Catalina/localhost/logitrack.xml
```
Contenido:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Context path="/logitrack" docBase="logitrack">
</Context>
```

---

## Comandos de Mantenimiento

### Ver logs en tiempo real
```bash
sudo tail -f /opt/tomcat/logs/catalina.out
```

### Reiniciar aplicación
```bash
sudo systemctl restart tomcat
```

### Ver aplicaciones desplegadas
```bash
ls /opt/tomcat/webapps/
```

### Limpiar logs antiguos
```bash
sudo find /opt/tomcat/logs/ -name "*.log" -mtime +7 -delete
sudo find /opt/tomcat/logs/ -name "*.txt" -mtime +7 -delete
```

### Backup de la aplicación
```bash
# Backup del WAR
sudo cp /opt/tomcat/webapps/logitrack.war ~/backup/logitrack-$(date +%Y%m%d).war

# Backup de la BD
mysqldump -u campus2023 -p logitrack_db > ~/backup/logitrack_db-$(date +%Y%m%d).sql
```

### Desplegar nueva versión
```bash
# 1. Compilar nuevo WAR
cd /ruta/proyecto
mvn clean package -DskipTests

# 2. Detener Tomcat
sudo systemctl stop tomcat

# 3. Backup de versión anterior
sudo cp /opt/tomcat/webapps/logitrack.war ~/backup/logitrack-old.war

# 4. Eliminar versión anterior
sudo rm -rf /opt/tomcat/webapps/logitrack
sudo rm -f /opt/tomcat/webapps/logitrack.war

# 5. Copiar nueva versión
sudo cp target/logitrack.war /opt/tomcat/webapps/
sudo chown tomcat:tomcat /opt/tomcat/webapps/logitrack.war

# 6. Iniciar Tomcat
sudo systemctl start tomcat

# 7. Monitorear despliegue
sudo tail -f /opt/tomcat/logs/catalina.out
```

---

## Resumen de Configuración Final

### Credenciales MySQL:
- **Usuario**: campus2023
- **Contraseña**: campus2023
- **Base de datos**: logitrack_db
- **Puerto**: 3306

### Versiones:
- **Java**: 17
- **Tomcat**: 10.0.20
- **Spring Boot**: 3.4.0
- **Maven**: 3.6.3+

### URLs de Acceso:
- **Aplicación**: http://localhost:8080/logitrack
- **Swagger UI**: http://localhost:8080/logitrack/swagger-ui.html
- **API Docs**: http://localhost:8080/logitrack/v3/api-docs

### Ubicaciones:
- **Tomcat**: /opt/tomcat
- **WAR**: /opt/tomcat/webapps/logitrack.war
- **Logs**: /opt/tomcat/logs/catalina.out
- **Config**: /opt/tomcat/conf/

---

## Checklist de Despliegue

- [ ] MySQL instalado y corriendo
- [ ] Usuario `campus2023` creado con contraseña `campus2023`
- [ ] Base de datos `logitrack_db` creada
- [ ] Java 17 instalado y JAVA_HOME configurado
- [ ] Tomcat 10.0.20 instalado en /opt/tomcat
- [ ] Servicio systemd de Tomcat configurado
- [ ] Tomcat corriendo (puerto 8080)
- [ ] Maven instalado
- [ ] Proyecto compilado (`mvn clean package`)
- [ ] WAR generado en target/logitrack.war
- [ ] WAR copiado a /opt/tomcat/webapps/
- [ ] Tomcat desplegó la aplicación (directorio logitrack/ existe)
- [ ] Aplicación responde en http://localhost:8080/logitrack
- [ ] Swagger UI accesible
- [ ] Conexión a MySQL exitosa (revisar logs)

---

Última actualización: 2025-11-14