package com.logitrack.config;

import com.logitrack.model.Auditoria;
import com.logitrack.model.Usuario;
import jakarta.persistence.*;
import org.springframework.stereotype.Component;

@Component
public class AuditoriaListener {

    @PersistenceContext
    private EntityManager em;

    @PrePersist
    public void prePersist(Object entity) {
        registrar(entity, Auditoria.Operacion.INSERT, null, entity);
    }

    @PreUpdate
    public void preUpdate(Object entity) {
        Object old = em.find(entity.getClass(), getId(entity));
        registrar(entity, Auditoria.Operacion.UPDATE, old, entity);
    }

    @PreRemove
    public void preRemove(Object entity) {
        registrar(entity, Auditoria.Operacion.DELETE, entity, null);
    }

    private void registrar(Object entity, Auditoria.Operacion operacion, Object anterior, Object nuevo) {
        Auditoria auditoria = new Auditoria();
        auditoria.setOperacion(operacion);
        auditoria.setEntidad(entity.getClass().getSimpleName());
        auditoria.setEntidadId(getId(entity));
        auditoria.setValoresAnteriores(anterior);
        auditoria.setValoresNuevos(nuevo);

        // Seguridad desactivada temporalmente: no se asigna usuario autenticado

        em.persist(auditoria);
    }

    private Long getId(Object entity) {
        try {
            var method = entity.getClass().getMethod("getId");
            return (Long) method.invoke(entity);
        } catch (Exception e) {
            return null;
        }
    }
}