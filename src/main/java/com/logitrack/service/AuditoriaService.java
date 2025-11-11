package com.logitrack.service;

import com.logitrack.model.Auditoria;
import com.logitrack.repository.AuditoriaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AuditoriaService {

    private final AuditoriaRepository repository;

    public List<Auditoria> findAll() {
        return repository.findAll();
    }

    public List<Auditoria> findUltimas(Integer limite) {
        List<Auditoria> ultimas = repository.findTop20ByOrderByFechaDesc();
        if (limite == null || limite >= ultimas.size()) {
            return ultimas;
        }
        return ultimas.subList(0, Math.max(0, limite));
    }

    public List<Auditoria> findByEntidad(String entidad) {
        return repository.findByEntidad(entidad);
    }

    public List<Auditoria> findByEntidadAndId(String entidad, Long entidadId) {
        return repository.findByEntidadAndEntidadId(entidad, entidadId);
    }

    public List<Auditoria> findByUsuario(Long usuarioId) {
        return repository.findByUsuarioId(usuarioId);
    }

    public List<Auditoria> findByOperacion(Auditoria.Operacion operacion) {
        return repository.findByOperacion(operacion);
    }

    public List<Auditoria> findByFechas(LocalDateTime inicio, LocalDateTime fin) {
        return repository.findByFechaBetween(inicio, fin);
    }
}