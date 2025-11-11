package com.logitrack.controller;

import com.logitrack.dto.MovimientoResponse;
import com.logitrack.dto.ReporteResumen;
import com.logitrack.model.Movimiento;
import com.logitrack.repository.MovimientoDetalleRepository;
import com.logitrack.repository.MovimientoRepository;
import com.logitrack.service.MovimientoService;
import com.logitrack.service.ReporteService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import com.logitrack.dto.ErrorResponseDTO;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/reportes")
@RequiredArgsConstructor
@Tag(name = "Reportes", description = "Reportes avanzados de movimientos de inventario")
public class ReporteController {

    private final MovimientoRepository movimientoRepository;
    private final MovimientoDetalleRepository detalleRepository;
    private final MovimientoService movimientoService;
    private final ReporteService reporteService;

    @GetMapping("/resumen")
    @Operation(
            summary = "Resumen general de stock y movimientos",
            description = "Devuelve stock por bodega, productos más movidos, productos con stock bajo y resumen por categoría. " +
                    "El parámetro 'threshold' es opcional; si no se envía se usa el valor por defecto configurado. " +
                    "Validación: 0 <= threshold <= maxThreshold"
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "OK - Resumen generado correctamente",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = ReporteResumen.class))),
            @ApiResponse(responseCode = "400", description = "BAD REQUEST - Parámetro 'threshold' inválido",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = ErrorResponseDTO.class)))
    })
    public ResponseEntity<ReporteResumen> resumen(
            @Parameter(description = "Umbral de stock bajo (opcional)", example = "25")
            @RequestParam(name = "threshold", required = false) Integer threshold) {
        return ResponseEntity.ok(threshold == null ? reporteService.generarResumen() : reporteService.generarResumen(threshold));
    }

    @GetMapping("/stock-bajo")
    @Operation(
            summary = "Productos con stock bajo (threshold configurable)",
            description = "Lista de productos con stock menor que el umbral. " +
                    "El parámetro 'threshold' es opcional; si no se envía se usa el valor por defecto configurado. " +
                    "Validación: 0 <= threshold <= maxThreshold"
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "OK - Lista de productos con stock bajo",
                    content = @Content(mediaType = "application/json")),
            @ApiResponse(responseCode = "400", description = "BAD REQUEST - Parámetro 'threshold' inválido",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = ErrorResponseDTO.class)))
    })
    public ResponseEntity<?> stockBajo(
            @Parameter(description = "Umbral de stock bajo (opcional)", example = "10")
            @RequestParam(name = "threshold", required = false) Integer threshold) {
        return ResponseEntity.ok((threshold == null ? reporteService.generarResumen() : reporteService.generarResumen(threshold)).getStockBajo());
    }

    @GetMapping("/movimientos/ultimos")
    @Operation(summary = "Obtener los últimos 10 movimientos")
    public ResponseEntity<List<MovimientoResponse>> ultimosMovimientos() {
        List<Movimiento> lista = movimientoRepository.findTop10ByOrderByFechaDesc();
        List<MovimientoResponse> resp = lista.stream().map(movimientoService::toResponsePublic).collect(Collectors.toList());
        return ResponseEntity.ok(resp);
    }

    @GetMapping("/movimientos/bodega/{bodegaId}/entradas")
    @Operation(summary = "Obtener entradas a una bodega")
    public ResponseEntity<List<MovimientoResponse>> entradasPorBodega(@PathVariable Long bodegaId) {
        List<Movimiento> lista = movimientoRepository.findEntradasByBodega(bodegaId);
        List<MovimientoResponse> resp = lista.stream().map(movimientoService::toResponsePublic).collect(Collectors.toList());
        return ResponseEntity.ok(resp);
    }

    @GetMapping("/movimientos/bodega/{bodegaId}/salidas")
    @Operation(summary = "Obtener salidas de una bodega")
    public ResponseEntity<List<MovimientoResponse>> salidasPorBodega(@PathVariable Long bodegaId) {
        List<Movimiento> lista = movimientoRepository.findSalidasByBodega(bodegaId);
        List<MovimientoResponse> resp = lista.stream().map(movimientoService::toResponsePublic).collect(Collectors.toList());
        return ResponseEntity.ok(resp);
    }

    @GetMapping("/movimientos/transferencias-desde/{bodegaId}")
    @Operation(summary = "Transferencias desde una bodega")
    public ResponseEntity<List<MovimientoResponse>> transferenciasDesde(@PathVariable Long bodegaId) {
        List<Movimiento> lista = movimientoRepository.findTransferenciasDesde(bodegaId);
        List<MovimientoResponse> resp = lista.stream().map(movimientoService::toResponsePublic).collect(Collectors.toList());
        return ResponseEntity.ok(resp);
    }

    @GetMapping("/movimientos/transferencias-hacia/{bodegaId}")
    @Operation(summary = "Transferencias hacia una bodega")
    public ResponseEntity<List<MovimientoResponse>> transferenciasHacia(@PathVariable Long bodegaId) {
        List<Movimiento> lista = movimientoRepository.findTransferenciasHacia(bodegaId);
        List<MovimientoResponse> resp = lista.stream().map(movimientoService::toResponsePublic).collect(Collectors.toList());
        return ResponseEntity.ok(resp);
    }

    @GetMapping("/movimientos/top-productos")
    @Operation(summary = "Productos más movidos (por cantidad total)")
    public ResponseEntity<List<Map<String, Object>>> productosMasMovidos() {
        List<Object[]> filas = detalleRepository.findProductosMasMovidos();
        List<Map<String, Object>> resp = new ArrayList<>();
        for (Object[] f : filas) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("productoId", f[0]);
            row.put("producto", f[1]);
            row.put("totalMovido", f[2]);
            resp.add(row);
        }
        return ResponseEntity.ok(resp);
    }
}