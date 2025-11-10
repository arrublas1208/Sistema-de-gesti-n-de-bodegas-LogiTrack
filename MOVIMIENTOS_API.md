# API de Movimientos de Inventario

## Descripción

El sistema de movimientos permite registrar y gestionar tres tipos de operaciones de inventario:

1. **ENTRADA**: Ingreso de mercancía a una bodega (ej: compra a proveedor)
2. **SALIDA**: Salida de mercancía de una bodega (ej: venta a cliente)
3. **TRANSFERENCIA**: Movimiento de mercancía entre bodegas

Cada movimiento actualiza automáticamente el inventario de las bodegas involucradas.

---

## Tipos de Movimientos

### 1. ENTRADA
- **Descripción**: Ingreso de productos a una bodega
- **Requiere**: `bodegaDestinoId` (bodega que recibe)
- **No requiere**: `bodegaOrigenId`
- **Efecto**: Incrementa el stock en la bodega destino
- **Ejemplo**: Llegó un pedido del proveedor

### 2. SALIDA
- **Descripción**: Salida de productos de una bodega
- **Requiere**: `bodegaOrigenId` (bodega de donde sale)
- **No requiere**: `bodegaDestinoId`
- **Efecto**: Decrementa el stock en la bodega origen
- **Ejemplo**: Venta a un cliente

### 3. TRANSFERENCIA
- **Descripción**: Movimiento entre bodegas
- **Requiere**: `bodegaOrigenId` y `bodegaDestinoId`
- **Efecto**: Decrementa en origen, incrementa en destino
- **Ejemplo**: Reabastecimiento entre sucursales

---

## Estructura de Datos

### MovimientoRequest (JSON)

```json
{
  "tipo": "ENTRADA | SALIDA | TRANSFERENCIA",
  "usuarioId": 1,
  "bodegaOrigenId": 1,      // Opcional según tipo
  "bodegaDestinoId": 2,     // Opcional según tipo
  "detalles": [
    {
      "productoId": 1,
      "cantidad": 10
    }
  ],
  "observaciones": "Texto opcional"
}
```

### MovimientoResponse (JSON)

```json
{
  "id": 1,
  "fecha": "2025-11-10T16:30:00",
  "tipo": "TRANSFERENCIA",
  "usuario": "Juan Pérez",
  "bodegaOrigen": "Bodega Central",
  "bodegaDestino": "Bodega Norte",
  "detalles": [
    {
      "id": 1,
      "producto": "Laptop Dell",
      "cantidad": 10
    }
  ],
  "observaciones": "Reabastecimiento mensual"
}
```

---

## Endpoints Disponibles

### 1. Listar Todos los Movimientos
```http
GET http://localhost:8080/api/movimientos
```

### 2. Obtener Movimiento por ID
```http
GET http://localhost:8080/api/movimientos/1
```

### 3. Filtrar por Tipo
```http
GET http://localhost:8080/api/movimientos/tipo/ENTRADA
GET http://localhost:8080/api/movimientos/tipo/SALIDA
GET http://localhost:8080/api/movimientos/tipo/TRANSFERENCIA
```

### 4. Movimientos de una Bodega
```http
GET http://localhost:8080/api/movimientos/bodega/1
```
Retorna todos los movimientos donde la bodega aparece como origen o destino.

### 5. Movimientos por Usuario
```http
GET http://localhost:8080/api/movimientos/usuario/1
```

### 6. Movimientos por Rango de Fechas
```http
GET http://localhost:8080/api/movimientos/rango-fechas?inicio=2025-11-01T00:00:00&fin=2025-11-30T23:59:59
```

---

## Crear Movimientos

### Ejemplo 1: ENTRADA - Compra a Proveedor

**Escenario**: Llegaron 20 Laptops Dell a la Bodega Central

```http
POST http://localhost:8080/api/movimientos
Content-Type: application/json

{
  "tipo": "ENTRADA",
  "usuarioId": 1,
  "bodegaDestinoId": 1,
  "detalles": [
    {
      "productoId": 1,
      "cantidad": 20
    }
  ],
  "observaciones": "Compra a proveedor ABC - Factura #12345"
}
```

**Efecto**:
- Stock de Laptop Dell en Bodega Central: 30 → 50 ✅

---

### Ejemplo 2: SALIDA - Venta a Cliente

**Escenario**: Se vendieron 5 Sillas de Oficina de la Bodega Norte

```http
POST http://localhost:8080/api/movimientos
Content-Type: application/json

{
  "tipo": "SALIDA",
  "usuarioId": 2,
  "bodegaOrigenId": 2,
  "detalles": [
    {
      "productoId": 2,
      "cantidad": 5
    }
  ],
  "observaciones": "Venta cliente XYZ - Pedido #678"
}
```

**Efecto**:
- Stock de Silla Oficina en Bodega Norte: 40 → 35 ✅

---

### Ejemplo 3: TRANSFERENCIA - Reabastecimiento entre Bodegas

**Escenario**: Transferir 10 Teclados RGB de Bodega Central a Bodega Sur

```http
POST http://localhost:8080/api/movimientos
Content-Type: application/json

{
  "tipo": "TRANSFERENCIA",
  "usuarioId": 1,
  "bodegaOrigenId": 1,
  "bodegaDestinoId": 3,
  "detalles": [
    {
      "productoId": 3,
      "cantidad": 10
    }
  ],
  "observaciones": "Reabastecimiento Bodega Sur - Stock bajo"
}
```

**Efecto**:
- Stock Teclado RGB en Bodega Central: 100 → 90 ✅
- Stock Teclado RGB en Bodega Sur: 40 → 50 ✅

---

### Ejemplo 4: Movimiento con Múltiples Productos

**Escenario**: Entrada de varios productos a la vez

```http
POST http://localhost:8080/api/movimientos
Content-Type: application/json

{
  "tipo": "ENTRADA",
  "usuarioId": 1,
  "bodegaDestinoId": 2,
  "detalles": [
    {
      "productoId": 1,
      "cantidad": 5
    },
    {
      "productoId": 3,
      "cantidad": 25
    },
    {
      "productoId": 4,
      "cantidad": 10
    }
  ],
  "observaciones": "Pedido mensual del proveedor"
}
```

**Efecto**:
- Stock Laptop Dell en Bodega Norte: 15 → 20 ✅
- Stock Teclado RGB en Bodega Norte: 60 → 85 ✅
- Stock Escritorio en Bodega Norte: 25 → 35 ✅

---

## Validaciones Automáticas

### 1. Validación de Bodegas según Tipo

**ENTRADA** → Solo debe especificar bodega destino:
```json
✅ Correcto:
{
  "tipo": "ENTRADA",
  "bodegaDestinoId": 1,
  "bodegaOrigenId": null
}

❌ Error:
{
  "tipo": "ENTRADA",
  "bodegaOrigenId": 1,  // NO debe especificarse
  "bodegaDestinoId": 1
}
```

**SALIDA** → Solo debe especificar bodega origen:
```json
✅ Correcto:
{
  "tipo": "SALIDA",
  "bodegaOrigenId": 1,
  "bodegaDestinoId": null
}
```

**TRANSFERENCIA** → Debe especificar ambas:
```json
✅ Correcto:
{
  "tipo": "TRANSFERENCIA",
  "bodegaOrigenId": 1,
  "bodegaDestinoId": 2
}

❌ Error:
{
  "tipo": "TRANSFERENCIA",
  "bodegaOrigenId": 1,
  "bodegaDestinoId": 1  // NO pueden ser iguales
}
```

---

### 2. Validación de Stock

**Para SALIDA y TRANSFERENCIA**, el sistema valida que haya stock suficiente:

```json
Ejemplo: Intentar sacar 100 Laptops cuando solo hay 30

Respuesta 400 BAD REQUEST:
{
  "code": "BUSINESS_ERROR",
  "details": {
    "message": "Stock insuficiente de 'Laptop Dell' en bodega 'Bodega Central'. Disponible: 30, Requerido: 100"
  },
  "timestamp": "2025-11-10T..."
}
```

---

### 3. Validación de Producto en Bodega

Si intentas sacar un producto que no existe en esa bodega:

```json
Respuesta 400 BAD REQUEST:
{
  "code": "BUSINESS_ERROR",
  "details": {
    "message": "El producto 'Monitor LG' no existe en la bodega 'Bodega Central'"
  },
  "timestamp": "2025-11-10T..."
}
```

---

### 4. Validación de Stock Máximo

Si una ENTRADA excede el stock máximo configurado:

```json
Respuesta 400 BAD REQUEST:
{
  "code": "BUSINESS_ERROR",
  "details": {
    "message": "Stock excede el máximo permitido (100) para producto 'Laptop Dell' en bodega 'Bodega Central'"
  },
  "timestamp": "2025-11-10T..."
}
```

---

## Actualización Automática de Inventario

### Flujo Completo

1. **Usuario crea movimiento** → POST /api/movimientos
2. **Sistema valida**:
   - Bodegas existen
   - Productos existen
   - Stock suficiente (si aplica)
   - Bodegas correctas según tipo
3. **Sistema crea registro en tabla `movimiento`**
4. **Sistema crea detalles en tabla `movimiento_detalle`**
5. **Sistema actualiza tabla `inventario_bodega`**:
   - ENTRADA: Incrementa stock en destino
   - SALIDA: Decrementa stock en origen
   - TRANSFERENCIA: Decrementa en origen + Incrementa en destino
6. **Sistema retorna respuesta exitosa**

### Logs de Ejemplo

```
INFO: Creando movimiento tipo: TRANSFERENCIA
INFO: TRANSFERENCIA: 10 Teclado RGB de bodega Bodega Central a bodega Bodega Sur
INFO: Movimiento creado exitosamente: ID=1
```

---

## Casos de Uso Prácticos

### Caso 1: Recepción de Mercancía

```bash
# Llegó pedido del proveedor
curl -X POST http://localhost:8080/api/movimientos \
  -H "Content-Type: application/json" \
  -d '{
    "tipo": "ENTRADA",
    "usuarioId": 1,
    "bodegaDestinoId": 1,
    "detalles": [
      {"productoId": 1, "cantidad": 50},
      {"productoId": 2, "cantidad": 100}
    ],
    "observaciones": "Pedido mensual"
  }'
```

### Caso 2: Venta a Cliente

```bash
# Cliente compró productos
curl -X POST http://localhost:8080/api/movimientos \
  -H "Content-Type: application/json" \
  -d '{
    "tipo": "SALIDA",
    "usuarioId": 2,
    "bodegaOrigenId": 1,
    "detalles": [
      {"productoId": 1, "cantidad": 2},
      {"productoId": 3, "cantidad": 1}
    ],
    "observaciones": "Venta mostrador - Cliente ABC"
  }'
```

### Caso 3: Reabastecimiento Interno

```bash
# Bodega Sur necesita reabastecimiento
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
    "observaciones": "Reabastecimiento - Stock bajo detectado"
  }'
```

### Caso 4: Verificar Stock Antes de Transferencia

```bash
# 1. Ver stock actual en origen
curl http://localhost:8080/api/inventario/bodega/1/producto/1

# 2. Si hay suficiente, hacer transferencia
curl -X POST http://localhost:8080/api/movimientos \
  -H "Content-Type: application/json" \
  -d '{...}'

# 3. Verificar stock actualizado
curl http://localhost:8080/api/inventario/bodega/1/producto/1
curl http://localhost:8080/api/inventario/bodega/2/producto/1
```

---

## Reportes y Consultas

### Historial de Movimientos de una Bodega

```bash
# Ver todos los movimientos de Bodega Central
curl http://localhost:8080/api/movimientos/bodega/1
```

### Movimientos del Día

```bash
curl "http://localhost:8080/api/movimientos/rango-fechas?inicio=2025-11-10T00:00:00&fin=2025-11-10T23:59:59"
```

### Todas las Entradas

```bash
curl http://localhost:8080/api/movimientos/tipo/ENTRADA
```

### Movimientos Realizados por un Usuario

```bash
curl http://localhost:8080/api/movimientos/usuario/1
```

---

## Eliminar Movimiento (⚠️ ADVERTENCIA)

```http
DELETE http://localhost:8080/api/movimientos/1
```

**IMPORTANTE**:
- Eliminar un movimiento **NO revierte** el inventario
- Solo se debe usar para corregir errores de captura
- El historial de inventario quedará inconsistente
- Considerar implementar un sistema de "anulación" en lugar de eliminación

---

## Integración con Inventario

El sistema de movimientos está completamente integrado con el inventario:

```
Movimiento Creado → Actualización Automática de inventario_bodega
```

**Ventajas**:
- ✅ Trazabilidad completa
- ✅ Historial de todos los cambios
- ✅ Stock siempre actualizado
- ✅ Validaciones en tiempo real
- ✅ Auditoría automática (cuando se implemente)

---

## Próximas Mejoras

1. **Sistema de Anulación**: En lugar de eliminar, anular movimientos con movimiento inverso
2. **Auditoría Automática**: Registrar en tabla `auditoria` cada movimiento
3. **Firmas Digitales**: Autorización de movimientos importantes
4. **Notificaciones**: Alertas cuando stock llega a mínimo después de salida
5. **Reportes Avanzados**: Excel, PDF con historial de movimientos

---

## ✅ Archivos Implementados

- ✅ [Movimiento.java](src/main/java/com/logitrack/model/Movimiento.java)
- ✅ [MovimientoDetalle.java](src/main/java/com/logitrack/model/MovimientoDetalle.java)
- ✅ [MovimientoRepository.java](src/main/java/com/logitrack/repository/MovimientoRepository.java)
- ✅ [MovimientoDetalleRepository.java](src/main/java/com/logitrack/repository/MovimientoDetalleRepository.java)
- ✅ [MovimientoRequest.java](src/main/java/com/logitrack/dto/MovimientoRequest.java)
- ✅ [MovimientoResponse.java](src/main/java/com/logitrack/dto/MovimientoResponse.java)
- ✅ [MovimientoService.java](src/main/java/com/logitrack/service/MovimientoService.java)
- ✅ [MovimientoController.java](src/main/java/com/logitrack/controller/MovimientoController.java)

## ✅ Compilación Exitosa

```
[INFO] BUILD SUCCESS
[INFO] 26 source files compiled
```

---

**Sistema de Movimientos Completo y Funcional** 🎉
