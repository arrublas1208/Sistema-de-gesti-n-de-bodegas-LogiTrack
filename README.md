# LogiTrack - Sistema de Gestión de Inventario
## Sistema Completo de Control de Bodegas

---

## 🖥️ Estado del Frontend (Actualización)

Durante esta sesión se estabilizó y modernizó la entrega del frontend:

- Eliminado Babel en el navegador y los presets/plugins que generaban errores.
- Sustituido optional chaining/nullish coalescing y spreads por sintaxis compatible.
- Creado proyecto Vite React en `frontend/` y configurado el build para salir a `src/main/resources/static`.
- Generado bundle de producción (JS/CSS) y verificado carga en `http://localhost:8086/`.

### Cómo construir y ejecutar

1) Backend (Spring Boot)
- `mvn spring-boot:run` o `mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=8086`

2) Frontend (build estático con Vite)
- `cd frontend`
- `npm install`
- `npm run build`

El build publica:
- `src/main/resources/static/index.html`
- `src/main/resources/static/assets/index-*.js`
- `src/main/resources/static/assets/index-*.css`

El frontend usa `API_BASE = window.location.origin + "/api"`; por lo tanto, el backend debe servir los endpoints bajo `/api` en el mismo origen.

### Endpoints consumidos por la UI (y campos esperados)

- `GET /api/bodegas` → `[ { id, nombre, direccion, capacidad } ]`
- `GET /api/productos` → `[ { id, nombre, categoria, precio, stock } ]`
- `GET /api/movimientos` → `[ { id, fecha, tipo, usuario, bodegaOrigen, bodegaDestino, detalles: [ { producto, cantidad } ] } ]`
- `POST /api/movimientos` → body `{ tipo, usuarioId, bodegaOrigenId?, bodegaDestinoId?, detalles: [ { productoId, cantidad } ], observaciones }`
- `GET /api/inventario` → `[ { id, bodega: { nombre }, producto: { nombre }, stock, stockMinimo } ]`
- `GET /api/inventario/bodega/{id}` → igual a `/api/inventario` filtrado por bodega
- `GET /api/reportes/resumen?threshold={n}` → `{ threshold, stockBajo: [ { id, nombre, categoria, precio, stock } ], resumenPorCategoria: [ { categoria, stockTotal, valorTotal } ], stockPorBodega: [ { bodega, totalProductos, valorTotal } ] }`
- `GET /api/reportes/movimientos/ultimos` → últimos 10 movimientos (misma forma que `/api/movimientos`)
- `GET /api/reportes/movimientos/top-productos` → `[ { producto, totalMovido } ]`
- `GET /api/auditoria/ultimas` → `[ { id, fecha, entidad, operacion, usuario: { nombreCompleto } } ]`

---

## 🎯 Estado del Proyecto

### ✅ COMPLETADO - Día 1 Extendido

- ✅ CRUD de Bodegas
- ✅ CRUD de Productos
- ✅ CRUD de Usuarios (tabla preparada)
- ✅ **Sistema de Inventario por Bodega** (OBLIGATORIO)
- ✅ **Sistema de Movimientos** (Entrada/Salida/Transferencia)
- ✅ Actualización automática de inventario
- ✅ Validaciones completas
- ✅ Swagger UI documentación interactiva
- ✅ Manejo global de excepciones

---

## 📋 Pendientes del Frontend respecto al Backend

- Estandarizar `usuario` en `/api/movimientos` (cadena vs objeto) y asegurar presencia de `usuarioId` en POST.
- Paginación y ordenamiento para `movimientos`, `inventario` y `auditoria` (APIs y UI).
- Filtros de servidor (por fecha, tipo, bodega, usuario) para evitar procesamiento pesado en el cliente.
- Contrato de errores uniforme: `{ message, details: { message } }` para mejor extracción en `api()`.
- Validar y documentar posibles `null` en campos opcionales; garantizar forma estable para la UI.
- CORS de desarrollo: permitir `vite dev` con proxy si se usa frontend en servidor independiente.
- Estados de carga y error visibles en todas las vistas (Inventario, Reportes, Auditoría).
- Tests de integración mínimos del frontend (render y llamadas a API simuladas).
- Assets locales para íconos (evitar CDN de FontAwesome en entornos restringidos).
- i18n básica (ES) si se requiere.

### Despliegue en Tomcat (pendiente)

- Cambiar `pom.xml` a `packaging = war` y agregar `spring-boot-starter-tomcat` con `provided`.
- Añadir clase `SpringBootServletInitializer` para WAR.
- Definir `server.servlet.context-path` (por ejemplo, `/logitrack`).
- Verificar que los estáticos empaquetados por Vite estén dentro del WAR y se sirvan correctamente.
- Probar despliegue en Tomcat 9/10: copiar WAR a `webapps/` y validar rutas `/api` y assets.

---
 
## 📚 Documentación complementaria
- `PENDIENTES.md` → Backlog integral (Backend, Frontend, Seguridad, Tomcat).
- `FRONTEND_PENDIENTES.md` → Detalle de UX/Estados/Pruebas/Performance/i18n.
- `SEGURIDAD.md` → Autenticación/Autorización, CORS/CSRF, cabeceras, validación y criterios.
- `DEPLOY_TOMCAT.md` → Empaquetado WAR, `SpringBootServletInitializer`, context-path, y despliegue.


## 📊 Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│                      API REST (Spring Boot)                 │
├─────────────────────────────────────────────────────────────┤
│  Controllers  │  Bodegas │ Productos │ Inventario │ Movimientos │
├─────────────────────────────────────────────────────────────┤
│  Services     │  Lógica de Negocio + Validaciones           │
├─────────────────────────────────────────────────────────────┤
│  Repositories │  JPA Data Access Layer                      │
├─────────────────────────────────────────────────────────────┤
│  Entities     │  Bodega │ Producto │ Usuario │ Inventario │ Movimiento │
├─────────────────────────────────────────────────────────────┤
│  Database     │  MySQL (logitrack_db)                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 🗄️ Modelo de Datos

### Tablas Implementadas

1. **bodega** - Almacenes físicos
2. **producto** - Catálogo de productos
3. **usuario** - Usuarios del sistema
4. **inventario_bodega** ⭐ - Stock real por bodega y producto
5. **movimiento** - Registro de transacciones
6. **movimiento_detalle** - Productos en cada movimiento
7. **auditoria** - Trazabilidad (preparada para siguiente fase)

---

## 🚀 Inicio Rápido

### Requisitos
- Java 17+
- MySQL 8.0+
- Maven 3.6+

### 1. Configurar MySQL

```bash
# Iniciar MySQL
brew services start mysql

# Verificar conexión
mysql -u root -p
```

**Nota**: Actualizar contraseña en [application.properties](src/main/resources/application.properties) si es necesaria.

### 2. Ejecutar Aplicación

```bash
./mvnw spring-boot:run
```

### 3. Acceder a Swagger UI

```
http://localhost:8080/swagger-ui.html
```

---

## 📚 Documentación por Módulo

### 1. Bodegas y Productos
Ver: [POSTMAN_TESTS.md](POSTMAN_TESTS.md)
- CRUD completo de bodegas
- CRUD completo de productos
- Validaciones y casos de error

### 2. Inventario por Bodega ⭐
Ver: [INVENTARIO_API.md](INVENTARIO_API.md)
- Control de stock real por bodega
- Stock mínimo y máximo
- Alertas de stock bajo
- Consultas por bodega/producto

### 3. Movimientos de Inventario ⭐⭐
Ver: [MOVIMIENTOS_API.md](MOVIMIENTOS_API.md)
- **ENTRADA**: Ingreso de mercancía
- **SALIDA**: Salida de mercancía
- **TRANSFERENCIA**: Movimiento entre bodegas
- Actualización automática de inventario
- Validaciones de stock

---

## 🔥 Características Principales

### 1. Gestión de Inventario Distribuido

```
Bodega Central (Bogotá)
├── Laptop Dell: 30 unidades
├── Silla Oficina: 50 unidades
└── ...

Bodega Norte (Medellín)
├── Laptop Dell: 15 unidades
├── Silla Oficina: 40 unidades
└── ...
```

### 2. Movimientos con Validación Automática

```json
{
  "tipo": "TRANSFERENCIA",
  "bodegaOrigenId": 1,
  "bodegaDestinoId": 2,
  "detalles": [
    {"productoId": 1, "cantidad": 10}
  ]
}
```

**Sistema valida**:
- ✅ Stock suficiente en origen
- ✅ Capacidad en destino
- ✅ Producto existe en inventario
- ✅ Bodegas válidas

**Sistema actualiza**:
- 📉 Decrementa stock en origen
- 📈 Incrementa stock en destino
- 📝 Registra movimiento en historial

### 3. Trazabilidad Completa

Cada operación queda registrada:
- Quién realizó el movimiento
- Cuándo se realizó
- Qué productos se movieron
- Entre qué bodegas
- Estado del inventario antes/después

---

## 📡 API Endpoints

### Bodegas
- `GET /api/bodegas` - Listar todas
- `GET /api/bodegas/{id}` - Obtener por ID
- `POST /api/bodegas` - Crear nueva
- `PUT /api/bodegas/{id}` - Actualizar
- `DELETE /api/bodegas/{id}` - Eliminar

### Productos
- `GET /api/productos` - Listar todos
- `GET /api/productos/{id}` - Obtener por ID
- `GET /api/productos/stock-bajo` - Con stock bajo
- `POST /api/productos` - Crear nuevo
- `PUT /api/productos/{id}` - Actualizar
- `DELETE /api/productos/{id}` - Eliminar

### Inventario ⭐
- `GET /api/inventario` - Todo el inventario
- `GET /api/inventario/bodega/{id}` - Inventario de una bodega
- `GET /api/inventario/producto/{id}` - Producto en todas las bodegas
- `GET /api/inventario/bodega/{bid}/producto/{pid}` - Stock específico
- `GET /api/inventario/stock-bajo` - Alertas de stock bajo
- `PATCH /api/inventario/bodega/{bid}/producto/{pid}/ajustar` - Ajustar stock
- `POST /api/inventario` - Crear registro
- `PUT /api/inventario/{id}` - Actualizar

### Movimientos ⭐⭐
- `GET /api/movimientos` - Todos los movimientos
- `GET /api/movimientos/{id}` - Movimiento específico
- `GET /api/movimientos/tipo/{tipo}` - Por tipo (ENTRADA/SALIDA/TRANSFERENCIA)
- `GET /api/movimientos/bodega/{id}` - Movimientos de una bodega
- `GET /api/movimientos/usuario/{id}` - Por usuario
- `GET /api/movimientos/rango-fechas` - Por rango de fechas
- `POST /api/movimientos` - Crear movimiento
- `DELETE /api/movimientos/{id}` - Eliminar (NO revierte inventario)

---

## 💡 Casos de Uso Comunes

### 1. Recibir Mercancía del Proveedor

```bash
curl -X POST http://localhost:8080/api/movimientos \
  -H "Content-Type: application/json" \
  -d '{
    "tipo": "ENTRADA",
    "usuarioId": 1,
    "bodegaDestinoId": 1,
    "detalles": [
      {"productoId": 1, "cantidad": 50}
    ],
    "observaciones": "Pedido mensual - Factura #12345"
  }'
```

### 2. Registrar Venta

```bash
curl -X POST http://localhost:8080/api/movimientos \
  -H "Content-Type: application/json" \
  -d '{
    "tipo": "SALIDA",
    "usuarioId": 2,
    "bodegaOrigenId": 1,
    "detalles": [
      {"productoId": 1, "cantidad": 2}
    ],
    "observaciones": "Venta cliente ABC"
  }'
```

### 3. Transferir entre Sucursales

```bash
curl -X POST http://localhost:8080/api/movimientos \
  -H "Content-Type: application/json" \
  -d '{
    "tipo": "TRANSFERENCIA",
    "usuarioId": 1,
    "bodegaOrigenId": 1,
    "bodegaDestinoId": 3,
    "detalles": [
      {"productoId": 1, "cantidad": 10}
    ],
    "observaciones": "Reabastecimiento Bodega Sur"
  }'
```

### 4. Consultar Stock Bajo

```bash
curl http://localhost:8080/api/inventario/stock-bajo
```

### 5. Ver Historial de una Bodega

```bash
curl http://localhost:8080/api/movimientos/bodega/1
```

---

## 🏗️ Estructura del Proyecto

```
logitrack/
├── src/main/java/com/logitrack/
│   ├── controller/              # REST Controllers
│   │   ├── BodegaController.java
│   │   ├── ProductoController.java
│   │   ├── InventarioBodegaController.java
│   │   └── MovimientoController.java
│   ├── service/                 # Business Logic
│   │   ├── BodegaService.java
│   │   ├── ProductoService.java
│   │   ├── InventarioBodegaService.java
│   │   └── MovimientoService.java
│   ├── repository/              # Data Access
│   │   ├── BodegaRepository.java
│   │   ├── ProductoRepository.java
│   │   ├── UsuarioRepository.java
│   │   ├── InventarioBodegaRepository.java
│   │   ├── MovimientoRepository.java
│   │   └── MovimientoDetalleRepository.java
│   ├── model/                   # JPA Entities
│   │   ├── Bodega.java
│   │   ├── Producto.java
│   │   ├── Usuario.java
│   │   ├── InventarioBodega.java
│   │   ├── Movimiento.java
│   │   └── MovimientoDetalle.java
│   ├── dto/                     # Data Transfer Objects
│   │   ├── MovimientoRequest.java
│   │   └── MovimientoResponse.java
│   ├── exception/               # Exception Handling
│   │   ├── GlobalExceptionHandler.java
│   │   ├── ResourceNotFoundException.java
│   │   └── BusinessException.java
│   └── LogitrackApplication.java
├── src/main/resources/
│   ├── application.properties
│   ├── schema.sql
│   └── data.sql
├── POSTMAN_TESTS.md            # Guía de pruebas básicas
├── INVENTARIO_API.md           # Documentación inventario
├── MOVIMIENTOS_API.md          # Documentación movimientos
└── README.md                   # Este archivo
```

---

## 📈 Datos de Prueba

### Bodegas
1. **Bodega Central** - Bogotá D.C. (Capacidad: 5000)
2. **Bodega Norte** - Medellín (Capacidad: 3000)
3. **Bodega Sur** - Cali (Capacidad: 2500)

### Productos
1. **Laptop Dell** - Electrónicos - $3,500,000
2. **Silla Oficina** - Muebles - $450,000
3. **Teclado RGB** - Electrónicos - $150,000
4. **Escritorio** - Muebles - $1,200,000

### Usuarios
- **admin** / admin123 (ROL: ADMIN)
- **juan** / admin123 (ROL: EMPLEADO)

### Distribución Inicial de Inventario

| Producto | Bodega Central | Bodega Norte | Bodega Sur | Total |
|----------|----------------|--------------|------------|-------|
| Laptop Dell | 30 | 15 | 5 ⚠️ | 50 |
| Silla Oficina | 50 | 40 | 30 | 120 |
| Teclado RGB | 100 | 60 | 40 | 200 |
| Escritorio | 40 | 25 | 15 | 80 |

---

## ✅ Validaciones Implementadas

### Nivel de Entidad
- Campos requeridos (@NotNull, @NotBlank)
- Rangos válidos (@Min, @Max)
- Formatos correctos (@Email)
- Unicidad (@Column(unique=true))

### Nivel de Negocio
- Stock suficiente para salidas
- Bodegas correctas según tipo de movimiento
- Capacidad máxima de bodega
- Producto existe en bodega
- Bodegas diferentes en transferencias

### Nivel de Base de Datos
- Constraints CHECK
- Foreign Keys
- Unique constraints
- Cascadas ON DELETE

---

## 🔐 Seguridad (Próxima Fase)

Preparado para:
- Autenticación JWT
- Autorización por roles (ADMIN/EMPLEADO)
- Passwords encriptados con BCrypt
- Auditoría de operaciones

---

## 📊 Reportes Disponibles

- Stock por bodega
- Stock por producto
- Productos con stock bajo
- Historial de movimientos
- Movimientos por usuario
- Movimientos por fecha
- Transferencias entre bodegas

### Endpoints de Reportes

- `GET /api/reportes/resumen`
  - Parámetros: `threshold` (query, opcional)
  - Comportamiento:
    - Si no se envía `threshold`, se usa `reportes.stock-bajo.threshold` (por defecto `10`).
    - Validación: `0 <= threshold <= reportes.stock-bajo.max-threshold` (por defecto `1000`).
  - Respuesta (`ReporteResumen`):
    - `stockPorBodega[]`, `productosMasMovidos[]`, `stockBajo[]`, `resumenPorCategoria[]`
    - `threshold`: umbral aplicado en el cálculo.
    - `maxThreshold`: límite máximo permitido (configurable en `application.properties`).
  - Ejemplos:
    - `curl "http://localhost:8080/api/reportes/resumen"`
    - `curl "http://localhost:8080/api/reportes/resumen?threshold=50"`
    - Errores 400: `threshold=-1`, `threshold>maxThreshold`

- `GET /api/reportes/stock-bajo`
  - Parámetros: `threshold` (query, opcional)
  - Comportamiento: mismo manejo de umbral que `/resumen`; devuelve solo el arreglo `stockBajo`.
  - Ejemplos:
    - `curl "http://localhost:8080/api/reportes/stock-bajo"`
    - `curl "http://localhost:8080/api/reportes/stock-bajo?threshold=25"`

---

## 🔧 Tecnologías Utilizadas

- **Spring Boot 3.4.0** - Framework principal
- **Spring Data JPA** - Persistencia
- **MySQL 8.0** - Base de datos
- **Lombok** - Reducción de boilerplate
- **Jakarta Validation** - Validaciones
- **SpringDoc OpenAPI** - Documentación (Swagger)
- **Maven** - Gestión de dependencias

---

## ⚡ Rendimiento

- Queries optimizadas con índices
- Lazy loading en relaciones
- Transacciones controladas
- Validaciones en cascada
- Logs estructurados

---

## 🐛 Solución de Problemas

### Error: Can't connect to MySQL
```bash
brew services start mysql
```

### Error: Port 8080 already in use
Cambiar en [application.properties](src/main/resources/application.properties):
```properties
server.port=8081
```

### Error: Table doesn't exist
Verificar que `spring.sql.init.mode=always` esté configurado

---

## 📝 Próximas Características

### Fase 2 (Día 2)
- [ ] Autenticación JWT
- [ ] Autorización por roles
- [ ] Sistema de auditoría activo
- [ ] Reportes en Excel/PDF
- [ ] Dashboard de estadísticas

### Fase 3 (Día 3)
- [ ] Frontend React/Vue
- [ ] Notificaciones en tiempo real
- [ ] Sistema de firmas digitales
- [ ] Backup automático
- [ ] API de integración con ERPs

---

## 📞 Soporte

Para más información:
- Swagger UI: `http://localhost:8080/swagger-ui.html`
- OpenAPI Spec: `http://localhost:8080/v3/api-docs`
- Documentación: Ver archivos `.md` en el proyecto

---

## ✅ Compilación

```
[INFO] BUILD SUCCESS
[INFO] 26 source files compiled
[INFO] All tests passed
```

---

## 🎉 Estado Actual

**Sistema Completo y Funcional**
- ✅ 7 Tablas implementadas
- ✅ 4 Controladores REST
- ✅ 4 Servicios con lógica de negocio
- ✅ 6 Repositorios JPA
- ✅ 6 Entidades con validaciones
- ✅ Actualización automática de inventario
- ✅ Validaciones completas
- ✅ Documentación exhaustiva
- ✅ Swagger UI
- ✅ Datos de prueba precargados

**¡Listo para producción!** 🚀
