package com.logitrack.service;

import com.logitrack.exception.ResourceNotFoundException;
import com.logitrack.exception.BusinessException;
import com.logitrack.model.Bodega;
import com.logitrack.repository.BodegaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class BodegaService {
    private final BodegaRepository repository;

    public List<Bodega> findAll() {
        return repository.findAll();
    }

    public Bodega findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Bodega no encontrada: " + id));
    }

    public Bodega save(Bodega bodega) {
        if (repository.existsByNombre(bodega.getNombre())) {
            throw new BusinessException("Ya existe una bodega con nombre: " + bodega.getNombre());
        }
        return repository.save(bodega);
    }

    public Bodega update(Long id, Bodega bodega) {
        Bodega existing = findById(id);
        if (!existing.getNombre().equals(bodega.getNombre()) && repository.existsByNombre(bodega.getNombre())) {
            throw new BusinessException("Nombre ya en uso");
        }
        bodega.setId(id);
        return repository.save(bodega);
    }

    public void delete(Long id) {
        if (!repository.existsById(id)) {
            throw new ResourceNotFoundException("Bodega no encontrada: " + id);
        }
        repository.deleteById(id);
    }
}
