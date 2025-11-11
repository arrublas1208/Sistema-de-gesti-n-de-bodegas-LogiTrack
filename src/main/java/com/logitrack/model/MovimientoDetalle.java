package com.logitrack.model;

import jakarta.persistence.*;
import com.logitrack.config.AuditoriaListener;
import jakarta.validation.constraints.*;
import lombok.*;

@Entity
@Table(name = "movimiento_detalle",
       uniqueConstraints = @UniqueConstraint(columnNames = {"movimiento_id", "producto_id"}))
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MovimientoDetalle {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "movimiento_id", nullable = false)
    @NotNull
    private Movimiento movimiento;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "producto_id", nullable = false)
    @NotNull
    private Producto producto;

    @Min(1)
    @Column(nullable = false)
    @NotNull
    private Integer cantidad;

    @Override
    public String toString() {
        return "MovimientoDetalle{" +
                "id=" + id +
                ", producto=" + (producto != null ? producto.getNombre() : "null") +
                ", cantidad=" + cantidad +
                '}';
    }
}
