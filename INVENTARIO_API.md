# API de Inventario por Bodega

## Descripción

La tabla `inventario_bodega` es **OBLIGATORIA** y crucial para el sistema LogiTrack. Esta tabla permite llevar el control del stock real de cada producto en cada bodega específica.

### ¿Por qué es necesaria?

Sin esta tabla, no podríamos responder preguntas como:
- ¿Cuántas Laptops Dell hay en la Bodega Central?
- ¿Qué productos tienen stock bajo en la Bodega Norte?
- ¿Cuál es el stock total de Teclados RGB en todas las bodegas?
- ¿Puedo transferir 10 Sillas de la Bodega Sur a la Bodega Norte?

---

## Estructura de la Tabla

```sql
CREATE TABLE inventario_bodega (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    bodega_id BIGINT NOT NULL,           -- FK a bodega
    producto_id BIGINT NOT NULL,         -- FK a producto
    stock INT NOT NULL DEFAULT 0,        -- Stock actual en esta bodega
    stock_minimo INT NOT NULL DEFAULT 10,-- Umbral de alerta
    stock_maximo INT NOT NULL DEFAULT 1000, -- Capacidad máxima
    ultima_actualizacion DATETIME,       -- Timestamp de último cambio
    UNIQUE (bodega_id, producto_id)      -- Un producto solo puede tener un registro por bodega
)
```

---

## Datos Iniciales

### Distribución de Stock por Bodega

**Bodega Central (Bogotá):**
- Laptop Dell: 30 unidades (min: 10, max: 100)
- Silla Oficina: 50 unidades (min: 20, max: 200)
- Teclado RGB: 100 unidades (min: 30, max: 300)
- Escritorio: 40 unidades (min: 15, max: 150)

**Bodega Norte (Medellín):**
- Laptop Dell: 15 unidades (min: 5, max: 50)
- Silla Oficina: 40 unidades (min: 15, max: 150)
- Teclado RGB: 60 unidades (min: 20, max: 200)
- Escritorio: 25 unidades (min: 10, max: 100)

**Bodega Sur (Cali):**
- Laptop Dell: 5 unidades ⚠️ STOCK BAJO
- Silla Oficina: 30 unidades
- Teclado RGB: 40 unidades
- Escritorio: 15 unidades

---

## Endpoints Disponibles

### 1. Listar Todo el Inventario
```http
GET http://localhost:8080/api/inventario
```

**Respuesta:**
```json
[
  {
    "id": 1,
    "bodega": {
      "id": 1,
      "nombre": "Bodega Central"
    },
    "producto": {
      "id": 1,
      "nombre": "Laptop Dell"
    },
    "stock": 30,
    "stockMinimo": 10,
    "stockMaximo": 100,
    "ultimaActualizacion": "2025-11-10T16:30:00"
  }
]
```

---

### 2. Inventario de una Bodega Específica
```http
GET http://localhost:8080/api/inventario/bodega/1
```

Retorna todos los productos disponibles en la Bodega Central.

---

### 3. Disponibilidad de un Producto en Todas las Bodegas
```http
GET http://localhost:8080/api/inventario/producto/1
```

Muestra en qué bodegas está disponible el producto con ID 1 (Laptop Dell) y cuánto stock hay en cada una.

---

### 4. Stock Específico (Bodega + Producto)
```http
GET http://localhost:8080/api/inventario/bodega/1/producto/1
```

Retorna el inventario específico de Laptop Dell en Bodega Central.

---

### 5. Productos con Stock Bajo (Todas las Bodegas)
```http
GET http://localhost:8080/api/inventario/stock-bajo
```

Retorna todos los productos cuyo stock actual está en o por debajo del `stock_minimo`.

**Respuesta:**
```json
[
  {
    "id": 9,
    "bodega": {
      "id": 3,
      "nombre": "Bodega Sur"
    },
    "producto": {
      "id": 1,
      "nombre": "Laptop Dell"
    },
    "stock": 5,
    "stockMinimo": 5,
    "stockMaximo": 30,
    "ultimaActualizacion": "2025-11-10T16:30:00"
  }
]
```

---

### 6. Stock Bajo en una Bodega Específica
```http
GET http://localhost:8080/api/inventario/bodega/3/stock-bajo
```

Retorna solo los productos con stock bajo en la Bodega Sur.

---

### 7. Stock Total de un Producto (Todas las Bodegas)
```http
GET http://localhost:8080/api/inventario/producto/1/total-stock
```

**Respuesta:**
```json
{
  "productoId": 1,
  "totalStock": 50
}
```

Suma el stock de Laptop Dell en todas las bodegas: 30 + 15 + 5 = 50

---

### 8. Crear Nuevo Inventario
```http
POST http://localhost:8080/api/inventario
Content-Type: application/json

{
  "bodega": {
    "id": 1
  },
  "producto": {
    "id": 5
  },
  "stock": 25,
  "stockMinimo": 5,
  "stockMaximo": 50
}
```

---

### 9. Actualizar Inventario Existente
```http
PUT http://localhost:8080/api/inventario/1
Content-Type: application/json

{
  "stock": 35,
  "stockMinimo": 15,
  "stockMaximo": 120
}
```

---

### 10. Ajustar Stock (Sumar o Restar)
```http
PATCH http://localhost:8080/api/inventario/bodega/1/producto/1/ajustar?cantidad=10
```

**Positivo**: Suma al stock (entrada de mercancía)
**Negativo**: Resta del stock (salida de mercancía)

**Ejemplo - Restar 5 unidades:**
```http
PATCH http://localhost:8080/api/inventario/bodega/1/producto/1/ajustar?cantidad=-5
```

**Validaciones:**
- No permite stock negativo
- No permite exceder el `stock_maximo`
- Retorna error si no hay suficiente stock

---

### 11. Eliminar Inventario
```http
DELETE http://localhost:8080/api/inventario/1
```

---

## Casos de Uso Prácticos

### Caso 1: Verificar disponibilidad antes de una venta
```bash
# ¿Hay 20 Laptops disponibles en Bodega Central?
curl http://localhost:8080/api/inventario/bodega/1/producto/1
```

### Caso 2: Alerta de reabastecimiento
```bash
# ¿Qué productos necesitan reabastecimiento?
curl http://localhost:8080/api/inventario/stock-bajo
```

### Caso 3: Registrar entrada de mercancía
```bash
# Llegaron 15 Teclados RGB a Bodega Norte
curl -X PATCH "http://localhost:8080/api/inventario/bodega/2/producto/3/ajustar?cantidad=15"
```

### Caso 4: Registrar venta
```bash
# Se vendieron 3 Sillas de Bodega Central
curl -X PATCH "http://localhost:8080/api/inventario/bodega/1/producto/2/ajustar?cantidad=-3"
```

### Caso 5: Verificar capacidad para transferencia
```bash
# ¿Cuánto stock hay de Escritorios en Bodega Sur?
curl http://localhost:8080/api/inventario/bodega/3/producto/4

# ¿Puedo enviar 10 unidades a otra bodega?
# Si la respuesta muestra stock >= 10, sí se puede
```

---

## Métodos de Utilidad en la Entidad

La clase `InventarioBodega` incluye métodos útiles:

```java
boolean isStockBajo()           // ¿Está en stock bajo?
boolean isStockAlto()           // ¿Está en stock alto?
int getEspacioDisponible()      // ¿Cuántas unidades más caben?
int getDeficitStock()           // ¿Cuántas unidades faltan para llegar al mínimo?
```

---

## Validaciones Implementadas

1. **Unicidad**: Un producto solo puede tener un registro de inventario por bodega
2. **Stock no negativo**: El stock no puede ser menor a 0
3. **Stock mínimo ≤ Stock máximo**: Validación de integridad
4. **Ajuste de stock**: No permite operaciones que resulten en stock negativo o excedan el máximo
5. **Relaciones**: Valida que la bodega y el producto existan antes de crear inventario

---

## Diferencia con la tabla `producto`

**Tabla `producto`:**
- Campo `stock`: Stock **total/global** del producto (puede ser calculado sumando todos los inventarios)
- Representa el catálogo de productos

**Tabla `inventario_bodega`:**
- Campo `stock`: Stock **real** en una **bodega específica**
- Representa la distribución física del inventario

---

## Integración con Movimientos

Cuando se implemente el sistema de movimientos:

**ENTRADA** → Incrementa `inventario_bodega.stock` de la bodega destino
**SALIDA** → Decrementa `inventario_bodega.stock` de la bodega origen
**TRANSFERENCIA** → Decrementa origen, incrementa destino

---

## ✅ Compilación Exitosa

```
[INFO] BUILD SUCCESS
[INFO] 18 source files compiled
```

Archivos creados:
- ✅ [InventarioBodega.java](src/main/java/com/logitrack/model/InventarioBodega.java)
- ✅ [InventarioBodegaRepository.java](src/main/java/com/logitrack/repository/InventarioBodegaRepository.java)
- ✅ [InventarioBodegaService.java](src/main/java/com/logitrack/service/InventarioBodegaService.java)
- ✅ [InventarioBodegaController.java](src/main/java/com/logitrack/controller/InventarioBodegaController.java)
