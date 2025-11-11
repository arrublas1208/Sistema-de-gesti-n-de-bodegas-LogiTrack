package com.logitrack.controller;

import com.logitrack.model.InventarioBodega;
import com.logitrack.service.InventarioBodegaService;
import io.swagger.v3.oas.annotations.*;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import com.logitrack.dto.ErrorResponseDTO;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/inventario")
@RequiredArgsConstructor
@Tag(name = "Inventario", description = "Gestión de Inventario por Bodega")
public class InventarioBodegaController {
    private final InventarioBodegaService service;

    @GetMapping
    @Operation(summary = "Obtener todo el inventario")
    public ResponseEntity<List<InventarioBodega>> getAll() {
        return ResponseEntity.ok(service.findAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener inventario por ID")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "OK - Inventario encontrado",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = InventarioBodega.class))),
            @ApiResponse(responseCode = "404", description = "NOT FOUND - Inventario no encontrado",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = ErrorResponseDTO.class)))
    })
    public ResponseEntity<InventarioBodega> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.findById(id));
    }

    @GetMapping("/bodega/{bodegaId}")
    @Operation(summary = "Obtener inventario de una bodega")
    public ResponseEntity<List<InventarioBodega>> getByBodega(@PathVariable Long bodegaId) {
        return ResponseEntity.ok(service.findByBodega(bodegaId));
    }

    @GetMapping("/producto/{productoId}")
    @Operation(summary = "Obtener inventario de un producto en todas las bodegas")
    public ResponseEntity<List<InventarioBodega>> getByProducto(@PathVariable Long productoId) {
        return ResponseEntity.ok(service.findByProducto(productoId));
    }

    @GetMapping("/bodega/{bodegaId}/producto/{productoId}")
    @Operation(summary = "Obtener inventario específico de un producto en una bodega")
    public ResponseEntity<InventarioBodega> getByBodegaAndProducto(
            @PathVariable Long bodegaId,
            @PathVariable Long productoId) {
        return ResponseEntity.ok(service.findByBodegaAndProducto(bodegaId, productoId));
    }

    @GetMapping("/stock-bajo")
    @Operation(summary = "Obtener todos los productos con stock bajo")
    public ResponseEntity<List<InventarioBodega>> getStockBajo() {
        return ResponseEntity.ok(service.findStockBajo());
    }

    @GetMapping("/bodega/{bodegaId}/stock-bajo")
    @Operation(summary = "Obtener productos con stock bajo en una bodega")
    public ResponseEntity<List<InventarioBodega>> getStockBajoByBodega(@PathVariable Long bodegaId) {
        return ResponseEntity.ok(service.findStockBajoByBodega(bodegaId));
    }

    @GetMapping("/producto/{productoId}/total-stock")
    @Operation(summary = "Obtener stock total de un producto en todas las bodegas")
    public ResponseEntity<Map<String, Integer>> getTotalStock(@PathVariable Long productoId) {
        Integer totalStock = service.getTotalStockByProducto(productoId);
        return ResponseEntity.ok(Map.of("productoId", productoId.intValue(), "totalStock", totalStock));
    }

    @PostMapping
    @Operation(summary = "Crear nuevo registro de inventario")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "CREATED - Inventario creado",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = InventarioBodega.class))),
            @ApiResponse(responseCode = "400", description = "BAD REQUEST - Error de negocio/validación",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = ErrorResponseDTO.class)))
    })
    public ResponseEntity<InventarioBodega> create(@Valid @RequestBody InventarioBodega inventario) {
        return new ResponseEntity<>(service.save(inventario), HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar inventario existente")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "OK - Inventario actualizado",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = InventarioBodega.class))),
            @ApiResponse(responseCode = "400", description = "BAD REQUEST - Error de negocio/validación",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = ErrorResponseDTO.class))),
            @ApiResponse(responseCode = "404", description = "NOT FOUND - Inventario no encontrado",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = ErrorResponseDTO.class)))
    })
    public ResponseEntity<InventarioBodega> update(
            @PathVariable Long id,
            @Valid @RequestBody InventarioBodega inventario) {
        return ResponseEntity.ok(service.update(id, inventario));
    }

    @PatchMapping("/bodega/{bodegaId}/producto/{productoId}/ajustar")
    @Operation(summary = "Ajustar stock de un producto en una bodega (positivo para sumar, negativo para restar)")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "OK - Stock ajustado",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = InventarioBodega.class))),
            @ApiResponse(responseCode = "400", description = "BAD REQUEST - Error de negocio/validación",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = ErrorResponseDTO.class))),
            @ApiResponse(responseCode = "404", description = "NOT FOUND - Inventario no encontrado",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = ErrorResponseDTO.class)))
    })
    public ResponseEntity<InventarioBodega> ajustarStock(
            @PathVariable Long bodegaId,
            @PathVariable Long productoId,
            @RequestParam Integer cantidad) {
        return ResponseEntity.ok(service.ajustarStock(bodegaId, productoId, cantidad));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar inventario")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "NO CONTENT - Inventario eliminado"),
            @ApiResponse(responseCode = "404", description = "NOT FOUND - Inventario no encontrado",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = ErrorResponseDTO.class)))
    })
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
