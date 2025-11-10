package com.logitrack.repository;

import com.logitrack.model.Producto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ProductoRepository extends JpaRepository<Producto, Long> {
    List<Producto> findByStockLessThan(int stock);

    @Query("SELECT p FROM Producto p ORDER BY p.stock DESC")
    List<Producto> findTopMovers();

    boolean existsByNombre(String nombre);
}
