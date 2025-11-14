-- Empresa inicial
INSERT INTO empresa (id, nombre) VALUES (1, 'Empresa Demo')
ON DUPLICATE KEY UPDATE nombre=nombre;

-- Usuarios iniciales
-- Contraseña para 'admin' y 'juan': admin123
-- Hash BCrypt generado: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
INSERT INTO usuario (username, password, rol, nombre_completo, email, empresa_id, cedula) VALUES
('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ADMIN', 'Administrador Sistema', 'admin@logitrack.com', 1, '1000000000'),
('juan', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'EMPLEADO', 'Juan Pérez', 'juan@logitrack.com', 1, '1010101010')
ON DUPLICATE KEY UPDATE username=username;

-- Bodegas iniciales (encargado_id=2 corresponde a 'juan')
INSERT INTO bodega (nombre, ubicacion, capacidad, empresa_id, encargado_id) VALUES
('Bodega Central', 'Bogotá D.C.', 5000, 1, 2),
('Bodega Norte', 'Medellín', 3000, 1, 2),
('Bodega Sur', 'Cali', 2500, 1, 2)
ON DUPLICATE KEY UPDATE nombre=nombre;

-- Productos iniciales
INSERT INTO producto (nombre, categoria, stock, precio, empresa_id) VALUES
('Laptop Dell', 'Electrónicos', 50, 3500000.00, 1),
('Silla Oficina', 'Muebles', 120, 450000.00, 1),
('Teclado RGB', 'Electrónicos', 200, 150000.00, 1),
('Escritorio', 'Muebles', 80, 1200000.00, 1)
ON DUPLICATE KEY UPDATE nombre=nombre;

-- Inventario por Bodega (Stock real distribuido)
-- Bodega Central (ID=1): Bodega principal
INSERT INTO inventario_bodega (bodega_id, producto_id, stock, stock_minimo, stock_maximo) VALUES
(1, 1, 30, 10, 100),  -- Laptop Dell: 30 unidades
(1, 2, 50, 20, 200),  -- Silla Oficina: 50 unidades
(1, 3, 100, 30, 300), -- Teclado RGB: 100 unidades
(1, 4, 40, 15, 150)   -- Escritorio: 40 unidades
ON DUPLICATE KEY UPDATE stock=stock;

-- Bodega Norte (ID=2): Bodega secundaria
INSERT INTO inventario_bodega (bodega_id, producto_id, stock, stock_minimo, stock_maximo) VALUES
(2, 1, 15, 5, 50),    -- Laptop Dell: 15 unidades
(2, 2, 40, 15, 150),  -- Silla Oficina: 40 unidades
(2, 3, 60, 20, 200),  -- Teclado RGB: 60 unidades
(2, 4, 25, 10, 100)   -- Escritorio: 25 unidades
ON DUPLICATE KEY UPDATE stock=stock;

-- Bodega Sur (ID=3): Bodega pequeña
INSERT INTO inventario_bodega (bodega_id, producto_id, stock, stock_minimo, stock_maximo) VALUES
(3, 1, 5, 5, 30),     -- Laptop Dell: 5 unidades
(3, 2, 30, 10, 100),  -- Silla Oficina: 30 unidades
(3, 3, 40, 15, 150),  -- Teclado RGB: 40 unidades
(3, 4, 15, 5, 80)     -- Escritorio: 15 unidades
ON DUPLICATE KEY UPDATE stock=stock;

-- Asegurar empresa para bodegas y productos existentes
UPDATE bodega SET empresa_id = 1 WHERE empresa_id IS NULL;
UPDATE producto SET empresa_id = 1 WHERE empresa_id IS NULL;
