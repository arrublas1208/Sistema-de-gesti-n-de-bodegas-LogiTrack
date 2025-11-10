package com.logitrack.service;

import com.logitrack.exception.ResourceNotFoundException;
import com.logitrack.exception.BusinessException;
import com.logitrack.model.Bodega;
import com.logitrack.model.InventarioBodega;
import com.logitrack.model.Producto;
import com.logitrack.repository.BodegaRepository;
import com.logitrack.repository.InventarioBodegaRepository;
import com.logitrack.repository.ProductoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class InventarioBodegaService {
    private final InventarioBodegaRepository repository;
    private final BodegaRepository bodegaRepository;
    private final ProductoRepository productoRepository;

    public List<InventarioBodega> findAll() {
        return repository.findAll();
    }

    public InventarioBodega findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Inventario no encontrado: " + id));
    }

    public List<InventarioBodega> findByBodega(Long bodegaId) {
        if (!bodegaRepository.existsById(bodegaId)) {
            throw new ResourceNotFoundException("Bodega no encontrada: " + bodegaId);
        }
        return repository.findByBodegaId(bodegaId);
    }

    public List<InventarioBodega> findByProducto(Long productoId) {
        if (!productoRepository.existsById(productoId)) {
            throw new ResourceNotFoundException("Producto no encontrado: " + productoId);
        }
        return repository.findByProductoId(productoId);
    }

    public InventarioBodega findByBodegaAndProducto(Long bodegaId, Long productoId) {
        return repository.findByBodegaIdAndProductoId(bodegaId, productoId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Inventario no encontrado para bodega " + bodegaId + " y producto " + productoId));
    }

    public List<InventarioBodega> findStockBajo() {
        return repository.findAllStockBajo();
    }

    public List<InventarioBodega> findStockBajoByBodega(Long bodegaId) {
        if (!bodegaRepository.existsById(bodegaId)) {
            throw new ResourceNotFoundException("Bodega no encontrada: " + bodegaId);
        }
        return repository.findStockBajoByBodega(bodegaId);
    }

    public Integer getTotalStockByProducto(Long productoId) {
        if (!productoRepository.existsById(productoId)) {
            throw new ResourceNotFoundException("Producto no encontrado: " + productoId);
        }
        return repository.getTotalStockByProducto(productoId);
    }

    public InventarioBodega save(InventarioBodega inventario) {
        // Validar que la bodega existe
        Bodega bodega = bodegaRepository.findById(inventario.getBodega().getId())
                .orElseThrow(() -> new ResourceNotFoundException("Bodega no encontrada"));

        // Validar que el producto existe
        Producto producto = productoRepository.findById(inventario.getProducto().getId())
                .orElseThrow(() -> new ResourceNotFoundException("Producto no encontrado"));

        // Validar que no exista ya un registro para esta combinación
        if (repository.existsByBodegaIdAndProductoId(bodega.getId(), producto.getId())) {
            throw new BusinessException("Ya existe inventario para este producto en esta bodega");
        }

        // Validar stock mínimo <= stock máximo
        if (inventario.getStockMinimo() > inventario.getStockMaximo()) {
            throw new BusinessException("El stock mínimo no puede ser mayor al stock máximo");
        }

        inventario.setBodega(bodega);
        inventario.setProducto(producto);
        return repository.save(inventario);
    }

    public InventarioBodega update(Long id, InventarioBodega inventario) {
        InventarioBodega existing = findById(id);

        // Validar stock mínimo <= stock máximo
        if (inventario.getStockMinimo() > inventario.getStockMaximo()) {
            throw new BusinessException("El stock mínimo no puede ser mayor al stock máximo");
        }

        existing.setStock(inventario.getStock());
        existing.setStockMinimo(inventario.getStockMinimo());
        existing.setStockMaximo(inventario.getStockMaximo());
        return repository.save(existing);
    }

    public InventarioBodega ajustarStock(Long bodegaId, Long productoId, Integer cantidad) {
        InventarioBodega inventario = findByBodegaAndProducto(bodegaId, productoId);
        int nuevoStock = inventario.getStock() + cantidad;

        if (nuevoStock < 0) {
            throw new BusinessException("Stock insuficiente. Stock actual: " + inventario.getStock() +
                    ", cantidad solicitada: " + Math.abs(cantidad));
        }

        if (nuevoStock > inventario.getStockMaximo()) {
            throw new BusinessException("El stock excedería el máximo permitido: " + inventario.getStockMaximo());
        }

        inventario.setStock(nuevoStock);
        return repository.save(inventario);
    }

    public void delete(Long id) {
        if (!repository.existsById(id)) {
            throw new ResourceNotFoundException("Inventario no encontrado: " + id);
        }
        repository.deleteById(id);
    }
}
