# 🚀 GUÍA RÁPIDA PARA EL TALLER

## ✅ LO QUE YA ESTÁ IMPLEMENTADO AL 100%

### 1. **Módulo PROVEEDORES** - COMPLETO ✅
- ✅ Modelo: `Proveedor.java`
- ✅ Repository: `ProveedorRepository.java`
- ✅ Service: `ProveedorService.java`
- ✅ Controller: `ProveedorController.java`
- ✅ Frontend: `ProveedoresView` (línea 1338 en main.jsx)
- ✅ En el menú y funcionando

### 2. **Base para otros 4 módulos** - 60% ✅
- ✅ Modelos Java completos
- ✅ Repositorios completos
- ✅ Esquema SQL completo
- ⏳ Servicios pendientes (copiar patrón)
- ⏳ Controladores pendientes (copiar patrón)
- ⏳ Frontend pendiente (copiar patrón)

---

## 📋 CÓMO COMPLETAR CUALQUIER MÓDULO EN 15 MINUTOS

### EJEMPLO: Implementar módulo de LOTES

#### PASO 1: Crear el Service (5 min)
```bash
# Copiar ProveedorService.java -> LoteService.java
# Cambiar:
- ProveedorService → LoteService
- ProveedorRepository → LoteRepository
- Proveedor → Lote
```

**Archivo**: `src/main/java/com/logitrack/service/LoteService.java`
```java
@Service
@RequiredArgsConstructor
@Transactional
public class LoteService {
    private final LoteRepository repository;
    private final UsuarioRepository usuarioRepository;

    private Long currentEmpresaId() {
        // ... copiar del ProveedorService
    }

    public List<Lote> findAll() {
        return repository.findByProductoId(...); // Adaptar
    }

    public Lote findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Lote no encontrado: " + id));
    }

    public Lote save(Lote lote) {
        // Validaciones específicas de lote
        return repository.save(lote);
    }

    // update(), delete()
}
```

#### PASO 2: Crear el Controller (3 min)
```bash
# Copiar ProveedorController.java -> LoteController.java
```

**Archivo**: `src/main/java/com/logitrack/controller/LoteController.java`
```java
@RestController
@RequestMapping("/api/lotes")
@RequiredArgsConstructor
@Tag(name = "Lotes")
public class LoteController {
    private final LoteService service;

    @GetMapping
    public ResponseEntity<List<Lote>> getAll() {
        return ResponseEntity.ok(service.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Lote> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.findById(id));
    }

    @PostMapping
    public ResponseEntity<Lote> create(@Valid @RequestBody Lote lote) {
        return new ResponseEntity<>(service.save(lote), HttpStatus.CREATED);
    }

    // PUT /{id}, DELETE /{id}
}
```

#### PASO 3: Actualizar el Frontend (7 min)
En `frontend/src/main.jsx`, reemplazar `LotesView()` (línea ~1437):

```javascript
function LotesView() {
  const list = useFetch((signal) => api("/lotes", { signal }), []);
  const [numeroLote, setNumeroLote] = React.useState("");
  const [cantidad, setCantidad] = React.useState("");
  const [fechaVencimiento, setFechaVencimiento] = React.useState("");
  const [status, setStatus] = React.useState("");

  const crear = async () => {
    try {
      await api("/lotes", {
        method: "POST",
        body: JSON.stringify({ numeroLote, cantidad, fechaVencimiento })
      });
      setNumeroLote(""); setCantidad(""); setFechaVencimiento("");
      list.reload();
      setStatus("✅ Lote creado exitosamente");
      setTimeout(() => setStatus(""), 3000);
    } catch (e) {
      setStatus("❌ " + String(e.message));
    }
  };

  return (
    <div>
      <Header title="Lotes" right={<><span className="status">{status}</span><button className="btn" onClick={list.reload}><Icon name="rotate" />Refrescar</button></>} />

      <div className="panel">
        <div className="panel-header"><strong>Registrar Lote</strong></div>
        <div className="panel-body">
          <div className="form">
            <div className="field"><label>Número de Lote*</label><input value={numeroLote} onChange={e=>setNumeroLote(e.target.value)} /></div>
            <div className="field"><label>Cantidad*</label><input type="number" value={cantidad} onChange={e=>setCantidad(e.target.value)} /></div>
            <div className="field"><label>Fecha Vencimiento</label><input type="date" value={fechaVencimiento} onChange={e=>setFechaVencimiento(e.target.value)} /></div>
            <div className="actions"><button className="btn" onClick={crear}><Icon name="plus" />Crear</button></div>
          </div>
        </div>
      </div>

      <div className="panel mt-8">
        <div className="panel-header"><strong>Listado de Lotes</strong></div>
        <div className="panel-body">
          {list.loading && <Loading/>}
          {list.error && <ErrorState error={list.error} onRetry={list.reload} />}
          {!list.loading && !list.error && Array.isArray(list.data) && list.data.length > 0 && (
            <table>
              <thead><tr><th>ID</th><th>Número</th><th>Cantidad</th><th>Vencimiento</th><th>Estado</th></tr></thead>
              <tbody>
                {list.data.map(l => (
                  <tr key={l.id}>
                    <td>{l.id}</td>
                    <td>{l.numeroLote}</td>
                    <td>{l.cantidad}</td>
                    <td>{l.fechaVencimiento || '—'}</td>
                    <td>{l.fechaVencimiento && new Date(l.fechaVencimiento) < new Date() ? '❌ Vencido' : '✅ Vigente'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </div>
  );
}
```

#### PASO 4: Probar (2 min)
```bash
# 1. Ejecutar SQL
mysql -u root -p logitrack_db < src/main/resources/schema.sql

# 2. Compilar backend
mvn clean install

# 3. Ejecutar
mvn spring-boot:run

# 4. Ir al navegador: http://localhost:8080
# 5. Click en "Lotes" en el menú
```

---

## 🎯 CHECKLIST PARA CADA MÓDULO

### Órdenes de Compra
- [ ] OrdenCompraService.java (copiar patrón)
- [ ] OrdenCompraController.java (copiar patrón)
- [ ] Actualizar OrdenesCompraView() en main.jsx

### Lotes
- [ ] LoteService.java (copiar patrón)
- [ ] LoteController.java (copiar patrón)
- [ ] Actualizar LotesView() en main.jsx

### Notificaciones
- [ ] NotificacionService.java (copiar patrón)
- [ ] NotificacionController.java (copiar patrón)
- [ ] Actualizar NotificacionesView() en main.jsx

### Devoluciones
- [ ] DevolucionService.java (copiar patrón)
- [ ] DevolucionController.java (copiar patrón)
- [ ] Actualizar DevolucionesView() en main.jsx

---

## 💡 TIPS PARA EL TALLER

### Si te piden implementar rápido:
1. **Ya tienes modelo y repository** - No toques eso
2. **Copia ProveedorService** - Cambia nombres
3. **Copia ProveedorController** - Cambia nombres
4. **Copia el código de ProveedoresView** - Adapta campos
5. **Listo en 15 minutos** ✅

### Si quieren ver funcionalidad compleja:
**Proveedores** ya está 100% funcional:
- CRUD completo
- Filtrado por empresa
- Campo activo/inactivo
- Validaciones
- Mensajes de éxito/error

### Funcionalidades especiales por módulo:

**Órdenes de Compra:**
- Estados (PENDIENTE → APROBADA → ENVIADA → RECIBIDA)
- Detalles (múltiples productos)
- Cálculo de totales
- Asociación con proveedor

**Lotes:**
- Tracking de vencimiento
- Alertas automáticas
- Trazabilidad (proveedor + orden)

**Notificaciones:**
- Generación automática
- Contador de no leídas
- Marcar como leída

**Devoluciones:**
- Dos tipos (A_PROVEEDOR, DE_CLIENTE)
- Estados de aprobación
- Actualización de inventario

---

## 📁 ARCHIVOS IMPORTANTES

### Backend:
```
src/main/java/com/logitrack/
├── model/          ← Modelos COMPLETOS ✅
├── repository/     ← Repositorios COMPLETOS ✅
├── service/        ← ProveedorService completo, otros pendientes
├── controller/     ← ProveedorController completo, otros pendientes
```

### Frontend:
```
frontend/src/main.jsx
├── Línea 105-112:  Menú actualizado ✅
├── Línea 1338-1417: ProveedoresView COMPLETO ✅
├── Línea 1420-1485: Otros módulos (placeholder)
├── Línea 1349-1356: Rutas agregadas ✅
```

### Base de datos:
```
src/main/resources/schema.sql
├── Líneas 109-202: Nuevas tablas ✅
```

---

## ⚡ COMANDOS RÁPIDOS

```bash
# Reiniciar BD con nuevas tablas
mysql -u root -p logitrack_db < src/main/resources/schema.sql

# Compilar cambios
mvn clean install

# Ejecutar
mvn spring-boot:run

# Ver logs
tail -f logs/spring-boot-logger.log

# Hot reload frontend (si aplica)
npm run dev
```

---

## 🎓 PARA DEMOSTRACIÓN EN TALLER

### Flujo recomendado:
1. **Mostrar Proveedores funcionando** (ya está al 100%)
2. **Explicar que los otros 4 siguen el mismo patrón**
3. **Si te piden implementar uno en vivo:**
   - Elegir Lotes (es el más simple)
   - Copiar Service y Controller (5 min)
   - Actualizar frontend (7 min)
   - Demostrar funcionando (3 min)

### Puntos de venta:
- ✅ 7 nuevas entidades
- ✅ Relaciones complejas (ManyToOne, OneToMany)
- ✅ Trazabilidad completa
- ✅ Validaciones de negocio
- ✅ UI responsive
- ✅ Patrón MVC completo
- ✅ REST API documentada con Swagger

---

**Fecha**: 2025-11-21
**Versión**: 2.0.0
**Estado**: LISTO PARA TALLER ✅
**Tiempo de implementación adicional**: 15 min por módulo
