package com.logitrack.service;

import com.logitrack.dto.ReporteResumen;
import com.logitrack.model.MovimientoDetalle;
import com.logitrack.model.Producto;
import com.logitrack.repository.BodegaRepository;
import com.logitrack.repository.MovimientoDetalleRepository;
import com.logitrack.repository.ProductoRepository;
import com.logitrack.repository.InventarioBodegaRepository;
import com.logitrack.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Value;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReporteService {

    private final ProductoRepository productoRepository;
    private final MovimientoDetalleRepository detalleRepository;
    private final BodegaRepository bodegaRepository;
    private final InventarioBodegaRepository inventarioBodegaRepository;

    @Value("${reportes.stock-bajo.threshold:10}")
    private int defaultThreshold;

    @Value("${reportes.stock-bajo.max-threshold:1000}")
    private int maxThreshold;

    public ReporteResumen generarResumen() {
        return generarResumen(defaultThreshold);
    }

    public ReporteResumen generarResumen(int threshold) {
        if (threshold < 0) {
            throw new BusinessException("El parámetro 'threshold' debe ser mayor o igual a 0");
        }
        if (threshold > maxThreshold) {
            throw new BusinessException("El parámetro 'threshold' no debe ser mayor a " + maxThreshold);
        }
        // Stock bajo (productos con stock < threshold)
        List<Producto> stockBajo = productoRepository.findByStockLessThan(threshold);

        // Productos más movidos (por cantidad total en movimientos)
        List<ReporteResumen.ProductoMovido> masMovidos = detalleRepository.findAll().stream()
                .collect(Collectors.groupingBy(
                        MovimientoDetalle::getProducto,
                        Collectors.summingInt(MovimientoDetalle::getCantidad)
                ))
                .entrySet().stream()
                .sorted((a, b) -> Integer.compare(b.getValue(), a.getValue()))
                .limit(5)
                .map(e -> new ReporteResumen.ProductoMovido(e.getKey().getNombre(), e.getValue()))
                .collect(Collectors.toList());

        // Stock por bodega (real): sumar inventarios por bodega
        List<ReporteResumen.StockPorBodega> stockPorBodega = bodegaRepository.findAll().stream()
                .map(b -> {
                    var inventarios = inventarioBodegaRepository.findByBodegaId(b.getId());
                    int totalProductos = inventarios.stream()
                            .mapToInt(inv -> inv.getStock() != null ? inv.getStock() : 0)
                            .sum();
                    double valorTotal = inventarios.stream()
                            .mapToDouble(inv -> {
                                int stock = inv.getStock() != null ? inv.getStock() : 0;
                                double precio = inv.getProducto() != null && inv.getProducto().getPrecio() != null ? inv.getProducto().getPrecio() : 0.0;
                                return stock * precio;
                            })
                            .sum();
                    return new ReporteResumen.StockPorBodega(b.getNombre(), totalProductos, valorTotal);
                })
                .collect(Collectors.toList());

        // Resumen por categoría (global): stock y valor total
        Map<String, List<Producto>> productosPorCategoria = productoRepository.findAll().stream()
                .collect(Collectors.groupingBy(p -> p.getCategoria() != null ? p.getCategoria() : "Sin categoría"));

        List<ReporteResumen.CategoriaResumen> resumenPorCategoria = productosPorCategoria.entrySet().stream()
                .map(e -> {
                    String categoria = e.getKey();
                    int stockTotal = e.getValue().stream()
                            .mapToInt(p -> p.getStock() != null ? p.getStock() : 0)
                            .sum();
                    double valorTotal = e.getValue().stream()
                            .mapToDouble(p -> (p.getStock() != null ? p.getStock() : 0) * (p.getPrecio() != null ? p.getPrecio() : 0.0))
                            .sum();
                    return new ReporteResumen.CategoriaResumen(categoria, stockTotal, valorTotal);
                })
                .sorted((a, b) -> Double.compare(b.getValorTotal(), a.getValorTotal()))
                .collect(Collectors.toList());

        return ReporteResumen.builder()
                .stockPorBodega(stockPorBodega)
                .productosMasMovidos(masMovidos)
                .stockBajo(stockBajo)
                .resumenPorCategoria(resumenPorCategoria)
                .threshold(threshold)
                .maxThreshold(maxThreshold)
                .build();
    }
}