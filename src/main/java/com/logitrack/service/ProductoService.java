package com.logitrack.service;

import com.logitrack.exception.ResourceNotFoundException;
import com.logitrack.exception.BusinessException;
import com.logitrack.model.Producto;
import com.logitrack.repository.ProductoRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class ProductoService {
    private final ProductoRepository repository;

    public List<Producto> findAll() {
        return repository.findAll();
    }

    public Producto findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Producto no encontrado: " + id));
    }

    public Producto save(Producto producto) {
        if (repository.existsByNombre(producto.getNombre())) {
            throw new BusinessException("Ya existe un producto con nombre: " + producto.getNombre());
        }
        return repository.save(producto);
    }

    public Producto update(Long id, Producto producto) {
        Producto existing = findById(id);
        if (!existing.getNombre().equals(producto.getNombre()) && repository.existsByNombre(producto.getNombre())) {
            throw new BusinessException("Nombre ya en uso");
        }
        producto.setId(id);
        return repository.save(producto);
    }

    public void delete(Long id) {
        if (!repository.existsById(id)) {
            throw new ResourceNotFoundException("Producto no encontrado: " + id);
        }
        repository.deleteById(id);
    }

    public List<Producto> findByStockLow(int threshold) {
        return repository.findByStockLessThan(threshold);
    }

    public List<Producto> findTopMovers() {
        return repository.findTopMovers();
    }

    public Page<Producto> search(String categoria, String nombreLike, Pageable pageable) {
        boolean hasCategoria = categoria != null && !categoria.isBlank();
        boolean hasNombre = nombreLike != null && !nombreLike.isBlank();
        if (hasCategoria && hasNombre) {
            return repository.findByCategoriaContainingIgnoreCaseAndNombreContainingIgnoreCase(categoria, nombreLike, pageable);
        }
        if (hasCategoria) {
            return repository.findByCategoriaContainingIgnoreCase(categoria, pageable);
        }
        if (hasNombre) {
            return repository.findByNombreContainingIgnoreCase(nombreLike, pageable);
        }
        return repository.findAll(pageable);
    }
}
