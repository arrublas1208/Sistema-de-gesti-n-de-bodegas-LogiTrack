package com.logitrack.service;

import com.logitrack.dto.MovimientoRequest;
import com.logitrack.dto.MovimientoResponse;
import com.logitrack.exception.BusinessException;
import com.logitrack.exception.ResourceNotFoundException;
import com.logitrack.model.*;
import com.logitrack.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class MovimientoService {

    private final MovimientoRepository movimientoRepository;
    private final MovimientoDetalleRepository detalleRepository;
    private final UsuarioRepository usuarioRepository;
    private final BodegaRepository bodegaRepository;
    private final ProductoRepository productoRepository;
    private final InventarioBodegaRepository inventarioBodegaRepository;

    public List<MovimientoResponse> findAll() {
        return movimientoRepository.findAll().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public MovimientoResponse findById(Long id) {
        Movimiento movimiento = movimientoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Movimiento no encontrado: " + id));
        return toResponse(movimiento);
    }

    public List<MovimientoResponse> findByTipo(Movimiento.TipoMovimiento tipo) {
        return movimientoRepository.findByTipo(tipo).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public List<MovimientoResponse> findByBodega(Long bodegaId) {
        if (!bodegaRepository.existsById(bodegaId)) {
            throw new ResourceNotFoundException("Bodega no encontrada: " + bodegaId);
        }
        return movimientoRepository.findByBodegaOrigenOrDestino(bodegaId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public List<MovimientoResponse> findByUsuario(Long usuarioId) {
        if (!usuarioRepository.existsById(usuarioId)) {
            throw new ResourceNotFoundException("Usuario no encontrado: " + usuarioId);
        }
        return movimientoRepository.findByUsuarioId(usuarioId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public List<MovimientoResponse> findByFechas(LocalDateTime inicio, LocalDateTime fin) {
        return movimientoRepository.findByFechaBetween(inicio, fin).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public MovimientoResponse create(MovimientoRequest request) {
        log.info("Creando movimiento tipo: {}", request.getTipo());

        // Validar usuario
        Usuario usuario = usuarioRepository.findById(request.getUsuarioId())
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado: " + request.getUsuarioId()));

        // Validar bodegas según tipo de movimiento
        Bodega bodegaOrigen = null;
        Bodega bodegaDestino = null;

        switch (request.getTipo()) {
            case ENTRADA:
                if (request.getBodegaDestinoId() == null) {
                    throw new BusinessException("Para movimiento de ENTRADA debe especificar bodega destino");
                }
                if (request.getBodegaOrigenId() != null) {
                    throw new BusinessException("Para movimiento de ENTRADA no debe especificar bodega origen");
                }
                bodegaDestino = bodegaRepository.findById(request.getBodegaDestinoId())
                        .orElseThrow(() -> new ResourceNotFoundException("Bodega destino no encontrada"));
                break;

            case SALIDA:
                if (request.getBodegaOrigenId() == null) {
                    throw new BusinessException("Para movimiento de SALIDA debe especificar bodega origen");
                }
                if (request.getBodegaDestinoId() != null) {
                    throw new BusinessException("Para movimiento de SALIDA no debe especificar bodega destino");
                }
                bodegaOrigen = bodegaRepository.findById(request.getBodegaOrigenId())
                        .orElseThrow(() -> new ResourceNotFoundException("Bodega origen no encontrada"));
                break;

            case TRANSFERENCIA:
                if (request.getBodegaOrigenId() == null || request.getBodegaDestinoId() == null) {
                    throw new BusinessException("Para movimiento de TRANSFERENCIA debe especificar bodega origen y destino");
                }
                if (request.getBodegaOrigenId().equals(request.getBodegaDestinoId())) {
                    throw new BusinessException("La bodega origen y destino no pueden ser la misma");
                }
                bodegaOrigen = bodegaRepository.findById(request.getBodegaOrigenId())
                        .orElseThrow(() -> new ResourceNotFoundException("Bodega origen no encontrada"));
                bodegaDestino = bodegaRepository.findById(request.getBodegaDestinoId())
                        .orElseThrow(() -> new ResourceNotFoundException("Bodega destino no encontrada"));
                break;
        }

        // Crear movimiento
        Movimiento movimiento = Movimiento.builder()
                .fecha(LocalDateTime.now())
                .tipo(request.getTipo())
                .usuario(usuario)
                .bodegaOrigen(bodegaOrigen)
                .bodegaDestino(bodegaDestino)
                .observaciones(request.getObservaciones())
                .build();

        // Validar y crear detalles
        for (MovimientoRequest.DetalleRequest detalleReq : request.getDetalles()) {
            Producto producto = productoRepository.findById(detalleReq.getProductoId())
                    .orElseThrow(() -> new ResourceNotFoundException("Producto no encontrado: " + detalleReq.getProductoId()));

            // Validar stock para SALIDA y TRANSFERENCIA
            if (request.getTipo() == Movimiento.TipoMovimiento.SALIDA ||
                request.getTipo() == Movimiento.TipoMovimiento.TRANSFERENCIA) {
                validarStockDisponible(bodegaOrigen, producto, detalleReq.getCantidad());
            }

            MovimientoDetalle detalle = MovimientoDetalle.builder()
                    .producto(producto)
                    .cantidad(detalleReq.getCantidad())
                    .build();

            movimiento.addDetalle(detalle);
        }

        // Guardar movimiento (cascade guardará los detalles)
        Movimiento saved = movimientoRepository.save(movimiento);

        // Actualizar inventario
        actualizarInventario(saved);

        log.info("Movimiento creado exitosamente: ID={}", saved.getId());
        return toResponse(saved);
    }

    private void validarStockDisponible(Bodega bodega, Producto producto, Integer cantidadRequerida) {
        InventarioBodega inventario = inventarioBodegaRepository
                .findByBodegaIdAndProductoId(bodega.getId(), producto.getId())
                .orElseThrow(() -> new BusinessException(
                        String.format("El producto '%s' no existe en la bodega '%s'",
                                producto.getNombre(), bodega.getNombre())));

        if (inventario.getStock() < cantidadRequerida) {
            throw new BusinessException(
                    String.format("Stock insuficiente de '%s' en bodega '%s'. Disponible: %d, Requerido: %d",
                            producto.getNombre(), bodega.getNombre(), inventario.getStock(), cantidadRequerida));
        }
    }

    private void actualizarInventario(Movimiento movimiento) {
        log.info("Actualizando inventario para movimiento ID: {}", movimiento.getId());

        for (MovimientoDetalle detalle : movimiento.getDetalles()) {
            switch (movimiento.getTipo()) {
                case ENTRADA:
                    // Incrementar stock en bodega destino
                    ajustarInventario(movimiento.getBodegaDestino(), detalle.getProducto(), detalle.getCantidad());
                    log.info("ENTRADA: +{} {} a bodega {}",
                            detalle.getCantidad(), detalle.getProducto().getNombre(), movimiento.getBodegaDestino().getNombre());
                    break;

                case SALIDA:
                    // Decrementar stock en bodega origen
                    ajustarInventario(movimiento.getBodegaOrigen(), detalle.getProducto(), -detalle.getCantidad());
                    log.info("SALIDA: -{} {} de bodega {}",
                            detalle.getCantidad(), detalle.getProducto().getNombre(), movimiento.getBodegaOrigen().getNombre());
                    break;

                case TRANSFERENCIA:
                    // Decrementar en origen
                    ajustarInventario(movimiento.getBodegaOrigen(), detalle.getProducto(), -detalle.getCantidad());
                    // Incrementar en destino
                    ajustarInventario(movimiento.getBodegaDestino(), detalle.getProducto(), detalle.getCantidad());
                    log.info("TRANSFERENCIA: {} {} de bodega {} a bodega {}",
                            detalle.getCantidad(), detalle.getProducto().getNombre(),
                            movimiento.getBodegaOrigen().getNombre(), movimiento.getBodegaDestino().getNombre());
                    break;
            }
        }
    }

    private void ajustarInventario(Bodega bodega, Producto producto, Integer ajuste) {
        InventarioBodega inventario = inventarioBodegaRepository
                .findByBodegaIdAndProductoId(bodega.getId(), producto.getId())
                .orElseGet(() -> {
                    // Si no existe inventario, crear uno nuevo (útil para ENTRADA)
                    log.info("Creando nuevo inventario para producto {} en bodega {}",
                            producto.getNombre(), bodega.getNombre());
                    return InventarioBodega.builder()
                            .bodega(bodega)
                            .producto(producto)
                            .stock(0)
                            .stockMinimo(10)
                            .stockMaximo(1000)
                            .build();
                });

        int nuevoStock = inventario.getStock() + ajuste;

        if (nuevoStock < 0) {
            throw new BusinessException(
                    String.format("Stock no puede ser negativo para producto '%s' en bodega '%s'",
                            producto.getNombre(), bodega.getNombre()));
        }

        if (nuevoStock > inventario.getStockMaximo()) {
            throw new BusinessException(
                    String.format("Stock excede el máximo permitido (%d) para producto '%s' en bodega '%s'",
                            inventario.getStockMaximo(), producto.getNombre(), bodega.getNombre()));
        }

        inventario.setStock(nuevoStock);
        inventarioBodegaRepository.save(inventario);

        log.debug("Stock actualizado: {} {} en bodega {} (antes: {}, ajuste: {}, después: {})",
                producto.getNombre(), bodega.getNombre(),
                inventario.getStock() - ajuste, ajuste, nuevoStock);
    }

    private MovimientoResponse toResponse(Movimiento movimiento) {
        return MovimientoResponse.builder()
                .id(movimiento.getId())
                .fecha(movimiento.getFecha())
                .tipo(movimiento.getTipo())
                .usuario(movimiento.getUsuario().getNombreCompleto())
                .bodegaOrigen(movimiento.getBodegaOrigen() != null ? movimiento.getBodegaOrigen().getNombre() : null)
                .bodegaDestino(movimiento.getBodegaDestino() != null ? movimiento.getBodegaDestino().getNombre() : null)
                .detalles(movimiento.getDetalles().stream()
                        .map(d -> MovimientoResponse.DetalleResponse.builder()
                                .id(d.getId())
                                .producto(d.getProducto().getNombre())
                                .cantidad(d.getCantidad())
                                .build())
                        .collect(Collectors.toList()))
                .observaciones(movimiento.getObservaciones())
                .build();
    }

    public void delete(Long id) {
        if (!movimientoRepository.existsById(id)) {
            throw new ResourceNotFoundException("Movimiento no encontrado: " + id);
        }
        // NOTA: Eliminar un movimiento NO revierte el inventario
        // Esto es intencional para mantener la integridad del historial
        movimientoRepository.deleteById(id);
        log.warn("Movimiento eliminado: ID={}. El inventario NO se revirtió.", id);
    }
}
