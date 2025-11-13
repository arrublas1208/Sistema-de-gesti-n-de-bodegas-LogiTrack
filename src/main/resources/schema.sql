CREATE DATABASE IF NOT EXISTS logitrack_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE logitrack_db;

-- Tabla Empresa (debe existir antes de FKs)
CREATE TABLE IF NOT EXISTS empresa (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Bodega
CREATE TABLE IF NOT EXISTS bodega (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    ubicacion VARCHAR(150) NOT NULL,
    capacidad INT NOT NULL CHECK (capacidad > 0),
    encargado VARCHAR(100) NOT NULL
);

-- Idempotente: agregar columna empresa_id a bodega si no existe
SET @col_bodega_emp := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'bodega' AND COLUMN_NAME = 'empresa_id'
);
SET @ddl_bodega_emp := IF(@col_bodega_emp = 0,
    'ALTER TABLE bodega ADD COLUMN empresa_id BIGINT NULL',
    'SELECT 1'
);
PREPARE stmt_bodega_emp FROM @ddl_bodega_emp; EXECUTE stmt_bodega_emp; DEALLOCATE PREPARE stmt_bodega_emp;

-- Agregar FK empresa a bodega si no existe
SET @fk_bodega_emp := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'bodega' AND CONSTRAINT_NAME = 'fk_bodega_empresa'
);
SET @ddl_fk_bodega_emp := IF(@fk_bodega_emp = 0,
    'ALTER TABLE bodega ADD CONSTRAINT fk_bodega_empresa FOREIGN KEY (empresa_id) REFERENCES empresa(id)',
    'SELECT 1'
);
PREPARE stmt_fk_bodega_emp FROM @ddl_fk_bodega_emp; EXECUTE stmt_fk_bodega_emp; DEALLOCATE PREPARE stmt_fk_bodega_emp;

-- Idempotente: agregar columna encargado_id a bodega si no existe
SET @col_bodega_enc := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'bodega' AND COLUMN_NAME = 'encargado_id'
);
SET @ddl_bodega_enc := IF(@col_bodega_enc = 0,
    'ALTER TABLE bodega ADD COLUMN encargado_id BIGINT NULL',
    'SELECT 1'
);
PREPARE stmt_bodega_enc FROM @ddl_bodega_enc; EXECUTE stmt_bodega_enc; DEALLOCATE PREPARE stmt_bodega_enc;

-- Agregar FK encargado a bodega si no existe
SET @fk_bodega_enc := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'bodega' AND CONSTRAINT_NAME = 'fk_bodega_encargado'
);
SET @ddl_fk_bodega_enc := IF(@fk_bodega_enc = 0,
    'ALTER TABLE bodega ADD CONSTRAINT fk_bodega_encargado FOREIGN KEY (encargado_id) REFERENCES usuario(id)',
    'SELECT 1'
);
PREPARE stmt_fk_bodega_enc FROM @ddl_fk_bodega_enc; EXECUTE stmt_fk_bodega_enc; DEALLOCATE PREPARE stmt_fk_bodega_enc;

-- Migración de datos: copiar bodega.encargado (texto) a bodega.encargado_id
SET @needs_update := (
    SELECT COUNT(*) FROM bodega WHERE encargado_id IS NULL
);
SET @ddl_update_enc := IF(@needs_update > 0,
    'UPDATE bodega b JOIN usuario u ON (u.nombre_completo = b.encargado OR u.username = b.encargado) SET b.encargado_id = u.id WHERE b.encargado_id IS NULL',
    'SELECT 1'
);
PREPARE stmt_update_enc FROM @ddl_update_enc; EXECUTE stmt_update_enc; DEALLOCATE PREPARE stmt_update_enc;

-- Eliminar columna antigua "encargado" si existe
SET @col_encargado_exists := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'bodega' AND COLUMN_NAME = 'encargado'
);
SET @ddl_drop_encargado := IF(@col_encargado_exists > 0,
    'ALTER TABLE bodega DROP COLUMN encargado',
    'SELECT 1'
);
PREPARE stmt_drop_encargado FROM @ddl_drop_encargado; EXECUTE stmt_drop_encargado; DEALLOCATE PREPARE stmt_drop_encargado;


-- Tabla Producto
CREATE TABLE IF NOT EXISTS producto (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    categoria VARCHAR(50) NOT NULL,
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0)
);

-- Idempotente: agregar columna empresa_id a producto si no existe
SET @col_producto_emp := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'producto' AND COLUMN_NAME = 'empresa_id'
);
SET @ddl_producto_emp := IF(@col_producto_emp = 0,
    'ALTER TABLE producto ADD COLUMN empresa_id BIGINT NULL',
    'SELECT 1'
);
PREPARE stmt_producto_emp FROM @ddl_producto_emp; EXECUTE stmt_producto_emp; DEALLOCATE PREPARE stmt_producto_emp;

-- Agregar FK empresa a producto si no existe
SET @fk_producto_emp := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'producto' AND CONSTRAINT_NAME = 'fk_producto_empresa'
);
SET @ddl_fk_producto_emp := IF(@fk_producto_emp = 0,
    'ALTER TABLE producto ADD CONSTRAINT fk_producto_empresa FOREIGN KEY (empresa_id) REFERENCES empresa(id)',
    'SELECT 1'
);
PREPARE stmt_fk_producto_emp FROM @ddl_fk_producto_emp; EXECUTE stmt_fk_producto_emp; DEALLOCATE PREPARE stmt_fk_producto_emp;

-- Tabla Inventario Bodega (OBLIGATORIA: Stock real por bodega)
CREATE TABLE IF NOT EXISTS inventario_bodega (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    bodega_id BIGINT NOT NULL,
    producto_id BIGINT NOT NULL,
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    stock_minimo INT NOT NULL DEFAULT 10,
    stock_maximo INT NOT NULL DEFAULT 1000,
    ultima_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (bodega_id) REFERENCES bodega(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES producto(id) ON DELETE CASCADE,
    UNIQUE KEY uniq_bodega_producto (bodega_id, producto_id),
    CONSTRAINT chk_stock_minmax CHECK (stock_minimo <= stock_maximo)
);

-- Tabla Usuario (para login y auditoría)
CREATE TABLE IF NOT EXISTS usuario (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    rol ENUM('ADMIN', 'EMPLEADO') NOT NULL,
    nombre_completo VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
);

-- Idempotente: agregar columna empresa_id a usuario si no existe
SET @col_empresa := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'usuario' AND COLUMN_NAME = 'empresa_id'
);
SET @ddl_emp := IF(@col_empresa = 0,
    'ALTER TABLE usuario ADD COLUMN empresa_id BIGINT NULL',
    'SELECT 1'
);
PREPARE stmt2 FROM @ddl_emp; EXECUTE stmt2; DEALLOCATE PREPARE stmt2;

-- Agregar FK si no existe
SET @fk_empresa := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'usuario' AND CONSTRAINT_NAME = 'fk_usuario_empresa'
);
SET @ddl_fk := IF(@fk_empresa = 0,
    'ALTER TABLE usuario ADD CONSTRAINT fk_usuario_empresa FOREIGN KEY (empresa_id) REFERENCES empresa(id)',
    'SELECT 1'
);
PREPARE stmt3 FROM @ddl_fk; EXECUTE stmt3; DEALLOCATE PREPARE stmt3;

-- Tabla Movimiento
CREATE TABLE IF NOT EXISTS movimiento (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipo ENUM('ENTRADA', 'SALIDA', 'TRANSFERENCIA') NOT NULL,
    usuario_id BIGINT NOT NULL,
    bodega_origen_id BIGINT NULL,
    bodega_destino_id BIGINT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuario(id),
    FOREIGN KEY (bodega_origen_id) REFERENCES bodega(id),
    FOREIGN KEY (bodega_destino_id) REFERENCES bodega(id),
    CONSTRAINT chk_bodegas CHECK (
        (tipo = 'ENTRADA' AND bodega_origen_id IS NULL AND bodega_destino_id IS NOT NULL) OR
        (tipo = 'SALIDA' AND bodega_origen_id IS NOT NULL AND bodega_destino_id IS NULL) OR
        (tipo = 'TRANSFERENCIA' AND bodega_origen_id IS NOT NULL AND bodega_destino_id IS NOT NULL)
    )
);

-- Idempotente: crear columna 'observaciones' si no existe
SET @col_exists := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'logitrack_db' AND TABLE_NAME = 'movimiento' AND COLUMN_NAME = 'observaciones'
);
SET @ddl := IF(@col_exists = 0,
    'ALTER TABLE movimiento ADD COLUMN observaciones VARCHAR(500) NULL',
    'SELECT 1'
);
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;


-- Tabla Detalle Movimiento
CREATE TABLE IF NOT EXISTS movimiento_detalle (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    movimiento_id BIGINT NOT NULL,
    producto_id BIGINT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    FOREIGN KEY (movimiento_id) REFERENCES movimiento(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES producto(id),
    UNIQUE KEY uniq_mov_prod (movimiento_id, producto_id)
);

-- Tabla Auditoría
CREATE TABLE IF NOT EXISTS auditoria (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    operacion ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_id BIGINT NULL,
    entidad VARCHAR(50) NOT NULL,
    entidad_id BIGINT NOT NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuario(id)
);
-- Ajustes finales: índices opcionales
