# LogiTrack - Sistema de Gestión de Inventario
## Día 1 - IMPLEMENTACIÓN COMPLETADA ✅

---

## Resumen de Implementación

Se han completado todos los pasos del 2 al 9:

### ✅ PASO 2 - Configuración
- [application.properties](src/main/resources/application.properties) configurado con:
  - Conexión MySQL en `localhost:3306`
  - Usuario: `root` / Password: `admin123`
  - JPA con Hibernate
  - Scripts SQL automáticos
  - Swagger UI habilitado

### ✅ PASO 3 - Scripts SQL
- [schema.sql](src/main/resources/schema.sql) - Creación de tablas:
  - bodega
  - producto
  - usuario
  - movimiento
  - movimiento_detalle
  - auditoria

- [data.sql](src/main/resources/data.sql) - Datos iniciales:
  - 2 usuarios (admin, juan)
  - 3 bodegas
  - 4 productos

### ✅ PASO 4 - Entidades JPA
- [Bodega.java](src/main/java/com/logitrack/model/Bodega.java)
- [Producto.java](src/main/java/com/logitrack/model/Producto.java)
- [Usuario.java](src/main/java/com/logitrack/model/Usuario.java)

### ✅ PASO 5 - Repositorios
- [BodegaRepository.java](src/main/java/com/logitrack/repository/BodegaRepository.java)
- [ProductoRepository.java](src/main/java/com/logitrack/repository/ProductoRepository.java)
- [UsuarioRepository.java](src/main/java/com/logitrack/repository/UsuarioRepository.java)

### ✅ PASO 6 - Excepciones Globales
- [GlobalExceptionHandler.java](src/main/java/com/logitrack/exception/GlobalExceptionHandler.java)
- [ResourceNotFoundException.java](src/main/java/com/logitrack/exception/ResourceNotFoundException.java)
- [BusinessException.java](src/main/java/com/logitrack/exception/BusinessException.java)

### ✅ PASO 7 - Servicios CRUD
- [BodegaService.java](src/main/java/com/logitrack/service/BodegaService.java)
- [ProductoService.java](src/main/java/com/logitrack/service/ProductoService.java)

### ✅ PASO 8 - Controladores REST
- [BodegaController.java](src/main/java/com/logitrack/controller/BodegaController.java)
- [ProductoController.java](src/main/java/com/logitrack/controller/ProductoController.java)

### ✅ PASO 9 - Documentación
- [POSTMAN_TESTS.md](POSTMAN_TESTS.md) - Guía completa de endpoints

---

## Requisitos Previos

1. **Java 17+** instalado
2. **MySQL 8.0+** instalado y corriendo
3. **Maven** (incluido en el proyecto como `mvnw`)

---

## Configuración de MySQL

### 1. Iniciar MySQL
```bash
# macOS con Homebrew
brew services start mysql

# O manualmente
mysql.server start
```

### 2. Verificar conexión
```bash
mysql -u root -p
# Ingresa tu contraseña (por defecto: admin123 según configuración)
```

### 3. El script schema.sql creará automáticamente la base de datos `logitrack_db`

**NOTA:** Si tu contraseña de MySQL es diferente a `admin123`, actualiza el archivo [application.properties](src/main/resources/application.properties):
```properties
spring.datasource.password=TU_CONTRASEÑA
```

---

## Ejecución del Proyecto

### Opción 1: Con Maven Wrapper (Recomendado)
```bash
./mvnw spring-boot:run
```

### Opción 2: Compilar y ejecutar JAR
```bash
./mvnw clean package
java -jar target/logitrack-0.0.1-SNAPSHOT.jar
```

### Opción 3: Desde IDE (IntelliJ, Eclipse, VSCode)
Ejecuta la clase principal: `com.logitrack.LogitrackApplication`

---

## Verificación del Sistema

### 1. Verificar que la aplicación está corriendo
La consola debe mostrar:
```
Started LogitrackApplication in X.XXX seconds
Tomcat started on port 8080
```

### 2. Acceder a Swagger UI
Abre en tu navegador:
```
http://localhost:8080/swagger-ui.html
```

### 3. Probar endpoints básicos

**Listar bodegas:**
```bash
curl http://localhost:8080/api/bodegas
```

**Listar productos:**
```bash
curl http://localhost:8080/api/productos
```

**Crear nueva bodega:**
```bash
curl -X POST http://localhost:8080/api/bodegas \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Bodega Este",
    "ubicacion": "Barranquilla",
    "capacidad": 2000,
    "encargado": "María Ruiz"
  }'
```

---

## Estructura del Proyecto

```
logitrack/
├── src/main/java/com/logitrack/
│   ├── controller/          # REST Controllers
│   │   ├── BodegaController.java
│   │   └── ProductoController.java
│   ├── service/             # Business Logic
│   │   ├── BodegaService.java
│   │   └── ProductoService.java
│   ├── repository/          # Data Access Layer
│   │   ├── BodegaRepository.java
│   │   ├── ProductoRepository.java
│   │   └── UsuarioRepository.java
│   ├── model/              # JPA Entities
│   │   ├── Bodega.java
│   │   ├── Producto.java
│   │   └── Usuario.java
│   ├── exception/          # Exception Handling
│   │   ├── GlobalExceptionHandler.java
│   │   ├── ResourceNotFoundException.java
│   │   └── BusinessException.java
│   └── LogitrackApplication.java  # Main Class
├── src/main/resources/
│   ├── application.properties  # Configuration
│   ├── schema.sql             # Database Schema
│   └── data.sql               # Initial Data
├── POSTMAN_TESTS.md           # API Testing Guide
├── README_DIA1.md             # This file
└── pom.xml                    # Maven Dependencies
```

---

## Endpoints Disponibles

### Bodegas
- `GET    /api/bodegas` - Listar todas
- `GET    /api/bodegas/{id}` - Obtener por ID
- `POST   /api/bodegas` - Crear nueva
- `PUT    /api/bodegas/{id}` - Actualizar
- `DELETE /api/bodegas/{id}` - Eliminar

### Productos
- `GET    /api/productos` - Listar todos
- `GET    /api/productos/{id}` - Obtener por ID
- `GET    /api/productos/stock-bajo?threshold=50` - Stock bajo
- `GET    /api/productos/top-movers` - Más solicitados
- `POST   /api/productos` - Crear nuevo
- `PUT    /api/productos/{id}` - Actualizar
- `DELETE /api/productos/{id}` - Eliminar

---

## Características Implementadas

✅ CRUD completo de Bodegas
✅ CRUD completo de Productos
✅ Validaciones en entidades JPA
✅ Manejo global de excepciones
✅ Respuestas HTTP estándar
✅ Swagger UI para documentación interactiva
✅ Queries personalizadas (stock bajo, top movers)
✅ Datos de prueba precargados
✅ Base de datos MySQL con esquema completo
✅ Arquitectura en capas (Controller → Service → Repository)

---

## Datos Iniciales

### Bodegas Precargadas
1. **Bodega Central** - Bogotá D.C. (5000 unidades)
2. **Bodega Norte** - Medellín (3000 unidades)
3. **Bodega Sur** - Cali (2500 unidades)

### Productos Precargados
1. **Laptop Dell** - Electrónicos (50 unidades) - $3,500,000
2. **Silla Oficina** - Muebles (120 unidades) - $450,000
3. **Teclado RGB** - Electrónicos (200 unidades) - $150,000
4. **Escritorio** - Muebles (80 unidades) - $1,200,000

### Usuarios Precargados
- **admin** / admin123 (ROL: ADMIN)
- **juan** / admin123 (ROL: EMPLEADO)

---

## Solución de Problemas

### Error: "Can't connect to MySQL server"
```bash
# Verifica que MySQL esté corriendo
mysql.server status

# Inicia MySQL si está detenido
brew services start mysql
# o
mysql.server start
```

### Error: "Access denied for user 'root'"
Actualiza la contraseña en [application.properties](src/main/resources/application.properties)

### Error: "Port 8080 already in use"
```bash
# Cambia el puerto en application.properties
server.port=8081
```

### Error: "Table doesn't exist"
Verifica que `spring.sql.init.mode=always` esté en application.properties

---

## Próximos Pasos (DÍA 2)

1. Sistema de Movimientos (Entrada/Salida/Transferencia)
2. Auditoría automática de operaciones
3. Autenticación JWT
4. Autorización por roles
5. Reportes avanzados
6. Frontend básico

---

## Compilación Exitosa ✅

```
[INFO] BUILD SUCCESS
[INFO] Total time:  1.650 s
[INFO] 14 source files compiled
```

---

## Contacto y Soporte

Para más información sobre las pruebas de API, consulta [POSTMAN_TESTS.md](POSTMAN_TESTS.md)

**FIN DEL DÍA 1** 🎉
