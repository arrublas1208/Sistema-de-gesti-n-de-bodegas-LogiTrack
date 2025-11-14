CREATE DATABASE IF NOT EXISTS logitrack_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE logitrack_db;

-- ========================================
-- PASO 1: Crear tablas base sin FKs
-- ========================================

-- Tabla Empresa (primera, no depende de nadie)
CREATE TABLE IF NOT EXISTS empresa (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Usuario (segunda, solo depende de empresa - FK se agrega después)
CREATE TABLE IF NOT EXISTS usuario (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    rol ENUM('ADMIN', 'EMPLEADO') NOT NULL,
    nombre_completo VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    cedula VARCHAR(20) NULL,
    empresa_id BIGINT NULL,
    UNIQUE KEY uk_usuario_cedula (cedula)
);

-- Tabla Bodega (tercera, depende de usuario como encargado - FK se agrega después)
CREATE TABLE IF NOT EXISTS bodega (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    ubicacion VARCHAR(150) NOT NULL,
    capacidad INT NOT NULL CHECK (capacidad > 0),
    empresa_id BIGINT NULL,
    encargado_id BIGINT NULL
);

-- Tabla Producto (cuarta, solo depende de empresa - FK se agrega después)
CREATE TABLE IF NOT EXISTS producto (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    categoria VARCHAR(50) NOT NULL,
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    empresa_id BIGINT NULL
);

-- Tabla Inventario Bodega (depende de bodega y producto - FKs se agregan después)
CREATE TABLE IF NOT EXISTS inventario_bodega (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    bodega_id BIGINT NOT NULL,
    producto_id BIGINT NOT NULL,
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    stock_minimo INT NOT NULL DEFAULT 10,
    stock_maximo INT NOT NULL DEFAULT 1000,
    ultima_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uniq_bodega_producto (bodega_id, producto_id),
    CONSTRAINT chk_stock_minmax CHECK (stock_minimo <= stock_maximo)
);

-- Tabla Movimiento (depende de usuario y bodegas - FKs se agregan después)
CREATE TABLE IF NOT EXISTS movimiento (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipo ENUM('ENTRADA', 'SALIDA', 'TRANSFERENCIA') NOT NULL,
    usuario_id BIGINT NOT NULL,
    bodega_origen_id BIGINT NULL,
    bodega_destino_id BIGINT NULL,
    observaciones VARCHAR(500) NULL,
    CONSTRAINT chk_bodegas CHECK (
        (tipo = 'ENTRADA' AND bodega_origen_id IS NULL AND bodega_destino_id IS NOT NULL) OR
        (tipo = 'SALIDA' AND bodega_origen_id IS NOT NULL AND bodega_destino_id IS NULL) OR
        (tipo = 'TRANSFERENCIA' AND bodega_origen_id IS NOT NULL AND bodega_destino_id IS NOT NULL)
    )
);

-- Tabla Detalle Movimiento (depende de movimiento y producto - FKs se agregan después)
CREATE TABLE IF NOT EXISTS movimiento_detalle (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    movimiento_id BIGINT NOT NULL,
    producto_id BIGINT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    UNIQUE KEY uniq_mov_prod (movimiento_id, producto_id)
);

-- Tabla Auditoría (depende de usuario - FK se agrega después)
CREATE TABLE IF NOT EXISTS auditoria (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    operacion ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_id BIGINT NULL,
    entidad VARCHAR(50) NOT NULL,
    entidad_id BIGINT NOT NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL
);

-- ========================================
-- PASO 2: Agregar Foreign Keys (idempotente)
-- ========================================

-- FK: usuario.empresa_id -> empresa.id
SET @fk_exists := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'usuario' AND CONSTRAINT_NAME = 'fk_usuario_empresa'
);
SET @sql := IF(@fk_exists = 0,
    'ALTER TABLE usuario ADD CONSTRAINT fk_usuario_empresa FOREIGN KEY (empresa_id) REFERENCES empresa(id)',
    'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- FK: bodega.empresa_id -> empresa.id
SET @fk_exists := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'bodega' AND CONSTRAINT_NAME = 'fk_bodega_empresa'
);
SET @sql := IF(@fk_exists = 0,
    'ALTER TABLE bodega ADD CONSTRAINT fk_bodega_empresa FOREIGN KEY (empresa_id) REFERENCES empresa(id)',
    'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- FK: bodega.encargado_id -> usuario.id
SET @fk_exists := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'bodega' AND CONSTRAINT_NAME = 'fk_bodega_encargado'
);
SET @sql := IF(@fk_exists = 0,
    'ALTER TABLE bodega ADD CONSTRAINT fk_bodega_encargado FOREIGN KEY (encargado_id) REFERENCES usuario(id)',
    'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- FK: producto.empresa_id -> empresa.id
SET @fk_exists := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'producto' AND CONSTRAINT_NAME = 'fk_producto_empresa'
);
SET @sql := IF(@fk_exists = 0,
    'ALTER TABLE producto ADD CONSTRAINT fk_producto_empresa FOREIGN KEY (empresa_id) REFERENCES empresa(id)',
    'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- FK: inventario_bodega.bodega_id -> bodega.id
SET @fk_exists := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'inventario_bodega' AND CONSTRAINT_NAME = 'fk_inventario_bodega'
);
SET @sql := IF(@fk_exists = 0,
    'ALTER TABLE inventario_bodega ADD CONSTRAINT fk_inventario_bodega FOREIGN KEY (bodega_id) REFERENCES bodega(id) ON DELETE CASCADE',
    'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- FK: inventario_bodega.producto_id -> producto.id
SET @fk_exists := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'inventario_bodega' AND CONSTRAINT_NAME = 'fk_inventario_producto'
);
SET @sql := IF(@fk_exists = 0,
    'ALTER TABLE inventario_bodega ADD CONSTRAINT fk_inventario_producto FOREIGN KEY (producto_id) REFERENCES producto(id) ON DELETE CASCADE',
    'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- FK: movimiento.usuario_id -> usuario.id
SET @fk_exists := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'movimiento' AND CONSTRAINT_NAME = 'fk_movimiento_usuario'
);
SET @sql := IF(@fk_exists = 0,
    'ALTER TABLE movimiento ADD CONSTRAINT fk_movimiento_usuario FOREIGN KEY (usuario_id) REFERENCES usuario(id)',
    'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- FK: movimiento.bodega_origen_id -> bodega.id
SET @fk_exists := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'movimiento' AND CONSTRAINT_NAME = 'fk_movimiento_bodega_origen'
);
SET @sql := IF(@fk_exists = 0,
    'ALTER TABLE movimiento ADD CONSTRAINT fk_movimiento_bodega_origen FOREIGN KEY (bodega_origen_id) REFERENCES bodega(id)',
    'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- FK: movimiento.bodega_destino_id -> bodega.id
SET @fk_exists := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'movimiento' AND CONSTRAINT_NAME = 'fk_movimiento_bodega_destino'
);
SET @sql := IF(@fk_exists = 0,
    'ALTER TABLE movimiento ADD CONSTRAINT fk_movimiento_bodega_destino FOREIGN KEY (bodega_destino_id) REFERENCES bodega(id)',
    'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- FK: movimiento_detalle.movimiento_id -> movimiento.id
SET @fk_exists := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'movimiento_detalle' AND CONSTRAINT_NAME = 'fk_detalle_movimiento'
);
SET @sql := IF(@fk_exists = 0,
    'ALTER TABLE movimiento_detalle ADD CONSTRAINT fk_detalle_movimiento FOREIGN KEY (movimiento_id) REFERENCES movimiento(id) ON DELETE CASCADE',
    'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- FK: movimiento_detalle.producto_id -> producto.id
SET @fk_exists := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'movimiento_detalle' AND CONSTRAINT_NAME = 'fk_detalle_producto'
);
SET @sql := IF(@fk_exists = 0,
    'ALTER TABLE movimiento_detalle ADD CONSTRAINT fk_detalle_producto FOREIGN KEY (producto_id) REFERENCES producto(id)',
    'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- FK: auditoria.usuario_id -> usuario.id
SET @fk_exists := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'auditoria' AND CONSTRAINT_NAME = 'fk_auditoria_usuario'
);
SET @sql := IF(@fk_exists = 0,
    'ALTER TABLE auditoria ADD CONSTRAINT fk_auditoria_usuario FOREIGN KEY (usuario_id) REFERENCES usuario(id)',
    'SELECT 1'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
