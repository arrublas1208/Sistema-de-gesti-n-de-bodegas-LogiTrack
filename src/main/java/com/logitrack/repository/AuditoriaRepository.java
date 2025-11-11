package com.logitrack.repository;

import com.logitrack.model.Auditoria;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AuditoriaRepository extends JpaRepository<Auditoria, Long> {

    List<Auditoria> findByEntidad(String entidad);

    List<Auditoria> findByEntidadAndEntidadId(String entidad, Long entidadId);

    List<Auditoria> findByUsuarioId(Long usuarioId);

    List<Auditoria> findByOperacion(Auditoria.Operacion operacion);

    List<Auditoria> findByFechaBetween(LocalDateTime inicio, LocalDateTime fin);

    List<Auditoria> findTop20ByOrderByFechaDesc();
}