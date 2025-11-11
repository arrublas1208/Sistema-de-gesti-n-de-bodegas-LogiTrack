# Pendientes del Frontend – LogiTrack

Este documento detalla los trabajos pendientes del frontend para completar funcionalidad, UX, calidad y mantenibilidad.

## Objetivos
- UI estable y consistente consumiendo `/api` del backend.
- Manejo robusto de carga, errores y datos nulos.
- Soporte de paginación, filtros y ordenamiento en listas grandes.
- Accesibilidad básica, i18n y pruebas de integración.

## Contratos de datos y errores
- Formato de errores esperado: `{ message, details?: { message } }`.
- Endpoints usados y forma de datos: ver `README.md` (sección “Endpoints consumidos”).
- Nullables: cualquier campo opcional debe renderizarse de forma segura (texto de fallback, `"N/D"`).

## Estados de carga y error
- Cada vista (`Dashboard`, `Bodegas`, `Productos`, `Inventario`, `Movimientos`, `Auditoría`) debe mostrar:
  - Loading: spinners o placeholders.
  - Empty: mensajes claros “Sin datos disponibles”.
  - Error: mensaje legible con `error.message` y opción “Reintentar”.

## Paginación, filtros y ordenamiento
- Paginación server-side con parámetros: `page`, `size`.
- Ordenamiento: `sort=campo,asc|desc`.
- Filtros comunes:
  - Movimientos: `fechaDesde`, `fechaHasta`, `tipo`, `bodegaOrigenId`, `bodegaDestinoId`, `usuarioId`.
  - Inventario: `bodegaId`, `productoId`, `stockMinimo`.
  - Productos: `categoria`, `nombreLike`.
- La UI debe construir query strings y mostrar el total de resultados.

## Formularios y validaciones (Movimientos)
- Campos requeridos según `tipo` (ENTRADA, SALIDA, TRANSFERENCIA).
- Validar cantidades (>0), selección de producto, origen/destino coherentes.
- Mensajes amigables y resaltado de errores de campo.
- Evitar doble envío: desactivar botón mientras se procesa.

## Gestión de estado y llamadas a API
- Hook `useFetch` con cancelación cuando cambia la ruta/filtros.
- `api()` debe manejar timeouts y parseo de errores uniformemente.
- Memoizar listas y cálculos derivados; evitar renders con `useMemo`/`useCallback` cuando aplique.

## Accesibilidad (A11y)
- Semántica correcta: encabezados, listas, roles.
- Focus visible, orden de tabulación, accesos por teclado.
- Contraste adecuado y etiquetas para controles.

## i18n
- Base en ES; preparar estructura para agregar otros idiomas.
- Extraer literales a un módulo `i18n`.

## Pruebas
- Vitest + React Testing Library.
- Pruebas de render básico por vista y mocks de API.
- Pruebas de interacción (filtros, paginación, envío de formularios).

## Performance
- Virtualización de tablas/listas si exceden ~200 filas.
- Lazy loading en vistas con datos pesados.
- Evitar trabajo innecesario en render: memoización y separación de componentes.

## Assets e íconos
- Reemplazar CDN de FontAwesome por assets locales empaquetados con Vite.

## Entregables y criterios de aceptación
- Vistas con estados de carga/error completos.
- Paginación/filtros/ordenamiento funcionando contra backend.
- Formularios validados y sin dobles envíos.
- Cobertura mínima de pruebas para vistas críticas.
- Sin errores en consola; performance aceptable en listas.