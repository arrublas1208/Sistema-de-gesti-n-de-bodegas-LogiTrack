package com.logitrack.controller;

import com.logitrack.dto.MovimientoRequest;
import com.logitrack.dto.MovimientoResponse;
import com.logitrack.model.Movimiento;
import com.logitrack.service.MovimientoService;
import io.swagger.v3.oas.annotations.*;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/movimientos")
@RequiredArgsConstructor
@Tag(name = "Movimientos", description = "Gestión de Movimientos de Inventario (Entrada/Salida/Transferencia)")
public class MovimientoController {

    private final MovimientoService service;

    @GetMapping
    @Operation(summary = "Obtener todos los movimientos")
    public ResponseEntity<List<MovimientoResponse>> getAll() {
        return ResponseEntity.ok(service.findAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener movimiento por ID")
    public ResponseEntity<MovimientoResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.findById(id));
    }

    @GetMapping("/tipo/{tipo}")
    @Operation(summary = "Obtener movimientos por tipo (ENTRADA, SALIDA, TRANSFERENCIA)")
    public ResponseEntity<List<MovimientoResponse>> getByTipo(@PathVariable Movimiento.TipoMovimiento tipo) {
        return ResponseEntity.ok(service.findByTipo(tipo));
    }

    @GetMapping("/bodega/{bodegaId}")
    @Operation(summary = "Obtener movimientos de una bodega (origen o destino)")
    public ResponseEntity<List<MovimientoResponse>> getByBodega(@PathVariable Long bodegaId) {
        return ResponseEntity.ok(service.findByBodega(bodegaId));
    }

    @GetMapping("/usuario/{usuarioId}")
    @Operation(summary = "Obtener movimientos realizados por un usuario")
    public ResponseEntity<List<MovimientoResponse>> getByUsuario(@PathVariable Long usuarioId) {
        return ResponseEntity.ok(service.findByUsuario(usuarioId));
    }

    @GetMapping("/rango-fechas")
    @Operation(summary = "Obtener movimientos por rango de fechas")
    public ResponseEntity<List<MovimientoResponse>> getByFechas(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime inicio,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fin) {
        return ResponseEntity.ok(service.findByFechas(inicio, fin));
    }

    @PostMapping
    @Operation(summary = "Crear nuevo movimiento (ENTRADA/SALIDA/TRANSFERENCIA)")
    public ResponseEntity<MovimientoResponse> create(@Valid @RequestBody MovimientoRequest request) {
        MovimientoResponse response = service.create(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar movimiento (NO revierte el inventario)",
               description = "ADVERTENCIA: Eliminar un movimiento NO revierte los cambios en el inventario. " +
                             "Use esta función solo para corrección de errores de captura.")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
