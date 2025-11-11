# LogiTrack - Pruebas API con Postman

## Configuración Base
- **Base URL**: `http://localhost:8080`
- **Content-Type**: `application/json`

---

## PASO 9 - Endpoints para Pruebas (DÍA 1)

### 1. BODEGAS (CRUD Completo)

#### 1.1 Listar todas las bodegas
```http
GET http://localhost:8080/api/bodegas
```

#### 1.2 Obtener bodega por ID
```http
GET http://localhost:8080/api/bodegas/1
```

#### 1.3 Crear nueva bodega
```http
POST http://localhost:8080/api/bodegas
Content-Type: application/json

{
  "nombre": "Bodega Este",
  "ubicacion": "Barranquilla",
  "capacidad": 2000,
  "encargado": "María Ruiz"
}
```

#### 1.4 Actualizar bodega
```http
PUT http://localhost:8080/api/bodegas/1
Content-Type: application/json

{
  "nombre": "Bodega Central",
  "ubicacion": "Bogotá D.C. - Centro",
  "capacidad": 6000,
  "encargado": "Carlos Gómez"
}
```

#### 1.5 Eliminar bodega
```http
DELETE http://localhost:8080/api/bodegas/4
```

---

### 2. PRODUCTOS (CRUD Completo + Endpoints Especiales)

#### 2.1 Listar todos los productos
```http
GET http://localhost:8080/api/productos
```

#### 2.2 Obtener producto por ID
```http
GET http://localhost:8080/api/productos/1
```

#### 2.3 Crear nuevo producto
```http
POST http://localhost:8080/api/productos
Content-Type: application/json

{
  "nombre": "Monitor LG 27 pulgadas",
  "categoria": "Electrónicos",
  "stock": 30,
  "precio": 850000.00
}
```

#### 2.4 Actualizar producto
```http
PUT http://localhost:8080/api/productos/1
Content-Type: application/json

{
  "nombre": "Laptop Dell XPS 15",
  "categoria": "Electrónicos",
  "stock": 45,
  "precio": 3800000.00
}
```

#### 2.5 Eliminar producto
```http
DELETE http://localhost:8080/api/productos/5
```

#### 2.6 Productos con stock bajo
```http
GET http://localhost:8080/api/productos/stock-bajo?threshold=50
```

#### 2.7 Productos más solicitados (Top Movers)
```http
GET http://localhost:8080/api/productos/top-movers
```

---

## 3. SWAGGER UI

Acceder a la documentación interactiva:
```
http://localhost:8080/swagger-ui.html
```

Acceder a la especificación OpenAPI:
```
http://localhost:8080/v3/api-docs
```

---

## 4. Verificar Base de Datos

### 4.1 Comprobar datos iniciales
Las siguientes consultas deberían retornar datos:

- **Bodegas**: `GET /api/bodegas` → 3 bodegas iniciales
- **Productos**: `GET /api/productos` → 4 productos iniciales

### 4.2 Datos esperados

**Bodegas:**
1. Bodega Central - Bogotá D.C.
2. Bodega Norte - Medellín
3. Bodega Sur - Cali

**Productos:**
1. Laptop Dell - Electrónicos - 50 unidades
2. Silla Oficina - Muebles - 120 unidades
3. Teclado RGB - Electrónicos - 200 unidades
4. Escritorio - Muebles - 80 unidades

---

## 5. Casos de Prueba de Validación

### 5.1 Error: Nombre duplicado (Bodega)
```http
POST http://localhost:8080/api/bodegas
Content-Type: application/json

{
  "nombre": "Bodega Central",
  "ubicacion": "Otra ubicación",
  "capacidad": 1000,
  "encargado": "Otro encargado"
}
```
**Respuesta esperada**: 400 BAD REQUEST
```json
{
  "code": "BUSINESS_ERROR",
  "details": {
    "message": "Ya existe una bodega con nombre: Bodega Central"
  },
  "timestamp": "2025-11-10T..."
}
```

### 5.2 Error: Campo requerido vacío
```http
POST http://localhost:8080/api/productos
Content-Type: application/json

{
  "nombre": "",
  "categoria": "Electrónicos",
  "stock": 10,
  "precio": 100000
}
```
**Respuesta esperada**: 400 BAD REQUEST con errores de validación

### 5.3 Error: Capacidad negativa
```http
POST http://localhost:8080/api/bodegas
Content-Type: application/json

{
  "nombre": "Bodega Test",
  "ubicacion": "Test",
  "capacidad": -100,
  "encargado": "Test"
}
```
**Respuesta esperada**: 400 BAD REQUEST con error de validación

### 5.4 Error: Recurso no encontrado
```http
GET http://localhost:8080/api/bodegas/999
```
**Respuesta esperada**: 404 NOT FOUND
```json
{
  "code": "NOT_FOUND",
  "details": {
    "message": "Bodega no encontrada: 999"
  },
  "timestamp": "2025-11-10T..."
}
```

---

## FIN DEL DÍA 1

### Entregables Completados:
✅ CRUD Bodega funcionando
✅ CRUD Producto funcionando
✅ Base de datos con datos iniciales
✅ Swagger UI disponible en `/swagger-ui.html`
✅ Validaciones y manejo de errores
✅ Endpoints adicionales (stock-bajo, top-movers)

### Próximos Pasos (DÍA 2):
- Implementar Sistema de Movimientos (Entrada/Salida/Transferencia)
- Sistema de Auditoría
- Autenticación y Autorización
- Reportes avanzados

---

## Reportes: Resumen y Stock Bajo

### 6.1 Resumen de reportes (umbral configurable)
```http
GET http://localhost:8080/api/reportes/resumen
```
**Expectativa**: 200 OK. El JSON incluye `threshold` (por defecto `10`) y `maxThreshold` (por defecto `1000`).

```http
GET http://localhost:8080/api/reportes/resumen?threshold=50
```
**Expectativa**: 200 OK. El JSON incluye `threshold: 50` y `maxThreshold` actual.

```http
GET http://localhost:8080/api/reportes/resumen?threshold=-1
```
**Expectativa**: 400 BAD REQUEST (`BusinessException`: "El parámetro 'threshold' debe ser mayor o igual a 0").

```http
GET http://localhost:8080/api/reportes/resumen?threshold=1001
```
**Expectativa**: 400 BAD REQUEST (`BusinessException`: incluye el `maxThreshold` configurado).

### 6.2 Productos con stock bajo (umbral configurable)
```http
GET http://localhost:8080/api/reportes/stock-bajo
```
**Expectativa**: 200 OK. Devuelve arreglo de productos con stock `< threshold` por defecto.

```http
GET http://localhost:8080/api/reportes/stock-bajo?threshold=25
```
**Expectativa**: 200 OK. Devuelve arreglo filtrado con `threshold=25`.

**Notas**
- Si no se suministra `threshold`, se usa `reportes.stock-bajo.threshold`.
- Validación: `0 <= threshold <= reportes.stock-bajo.max-threshold`.
