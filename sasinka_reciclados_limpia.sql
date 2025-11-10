-- ✅ ESTRUCTURA COMPLETA QUE SE CREARÁ:
-- 5 tablas principales con relaciones

-- 15 categorías de materiales

-- 45 materiales con precios

-- 15 pedidos con detalles

-- 2 vistas útiles

-- 6 funciones/procedimientos

-- 1 trigger para integridad

-- 6 índices de optimización

CREATE TABLE categoria (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    estado VARCHAR(20) DEFAULT 'Activo'
);

CREATE TABLE material (
    id_material SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    id_categoria INTEGER NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL DEFAULT 'kg',
    estado VARCHAR(20) DEFAULT 'Activo',
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

CREATE TABLE precio_material (
    id_precio SERIAL PRIMARY KEY,
    id_material INTEGER NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) DEFAULT 'Activo',
    FOREIGN KEY (id_material) REFERENCES material(id_material),
    CONSTRAINT chk_precio_positivo CHECK (precio > 0)
);

CREATE UNIQUE INDEX idx_precio_material_activo_unique 
ON precio_material (id_material) 
WHERE estado = 'Activo';

CREATE TABLE pedido (
    id_pedido SERIAL PRIMARY KEY,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_retiro TIMESTAMP,
    nombre_persona VARCHAR(100),
    ciudad VARCHAR(100),
    calle VARCHAR(150),
    altura VARCHAR(20),
    estado VARCHAR(20) DEFAULT 'Pendiente',
    observaciones TEXT
);

CREATE TABLE detalle_pedido (
    id_detalle SERIAL PRIMARY KEY,
    id_pedido INTEGER NOT NULL,
    id_material INTEGER NOT NULL,
    cantidad DECIMAL(10,2) CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) CHECK (precio_unitario > 0),
    subtotal DECIMAL(10,2) CHECK (subtotal >= 0),
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (id_material) REFERENCES material(id_material)
);

INSERT INTO categoria (nombre, descripcion) VALUES 
('Ferroso', 'Materiales que contienen hierro'),
('No Ferroso', 'Materiales sin contenido de hierro'),
('Plásticos', 'Materiales plásticos reciclables'),
('Vidrios', 'Vidrios de diferentes tipos y colores'),
('Papeles', 'Papeles y cartones para reciclar'),
('Electrónicos', 'Desechos electrónicos y componentes'),
('Textiles', 'Telas y materiales textiles usados'),
('Orgánicos', 'Materiales biodegradables orgánicos'),
('Peligrosos', 'Materiales que requieren manejo especial'),
('Metales Preciosos', 'Metales de alto valor como oro y plata'),
('Mixtos', 'Materiales compuestos de varios elementos'),
('Industrial', 'Residuos provenientes de procesos industriales'),
('Doméstico', 'Materiales comunes de hogares'),
('Construcción', 'Escombros y materiales de construcción'),
('Automotriz', 'Partes y materiales de vehículos');

INSERT INTO material (codigo, nombre, id_categoria, unidad_medida) VALUES
('AC001', 'Acero Estructural', 1, 'kg'),
('HI001', 'Hierro Forjado', 1, 'kg'),
('AC002', 'Acero Inoxidable', 1, 'kg'),
('HI002', 'Hierro Fundido', 1, 'kg'),
('AC003', 'Acero Galvanizado', 1, 'kg'),
('CH001', 'Chapa Ferrosa', 1, 'kg'),
('AL001', 'Alambre Hierro', 1, 'kg'),
('TU001', 'Tubo Hierro', 1, 'kg'),
('PE001', 'Perfil Hierro', 1, 'kg'),
('VI001', 'Viruta Ferrosa', 1, 'kg'),
('RE001', 'Rebaba Acero', 1, 'kg'),
('DE001', 'Desperdicio Hierro', 1, 'kg'),
('EN001', 'Engranaje Hierro', 1, 'kg'),
('HE001', 'Herraje Ferroso', 1, 'kg'),
('MA001', 'Maquina Hierro', 1, 'kg'),
('AL002', 'Aluminio Carter', 2, 'kg'),
('AL003', 'Aluminio Perfil', 2, 'kg'),
('AL004', 'Aluminio Segunda', 2, 'kg'),
('AN001', 'Antimonio', 2, 'kg'),
('BA001', 'Bateria Plomo', 2, 'kg'),
('BR001', 'Bronce Común', 2, 'kg'),
('CO001', 'Cobre Cable', 2, 'kg'),
('ES001', 'Estañado', 2, 'kg'),
('PL001', 'Plomo Blando', 2, 'kg'),
('ZI001', 'Zinc Industrial', 2, 'kg'),
('NI001', 'Níquel Puro', 2, 'kg'),
('MA002', 'Magnesio', 2, 'kg'),
('LA001', 'Latón Amarillo', 2, 'kg'),
('CO002', 'Cobre Milberry', 2, 'kg'),
('BR002', 'Bronce Fosforoso', 2, 'kg'),
('BA002', 'Bateria c/a', 2, 'unidad'),
('BA003', 'Bateria c/gel', 2, 'unidad'),
('BA004', 'Bateria Moto', 2, 'unidad'),
('BO001', 'Bocha Cobre', 2, 'unidad'),
('RA001', 'Radiador Aluminio c/Cobre', 2, 'unidad'),
('RA002', 'Radiadores Bronce', 2, 'unidad'),
('MO001', 'Motor Eléctrico', 2, 'unidad'),
('TR001', 'Transformador Cobre', 2, 'unidad'),
('CO003', 'Condensador Aire', 2, 'unidad'),
('RE002', 'Relé Cobre', 2, 'unidad'),
('IN001', 'Interruptor Bronce', 2, 'unidad'),
('TU002', 'Tubo Cobre', 2, 'unidad'),
('VA001', 'Válvula Bronce', 2, 'unidad'),
('HE002', 'Herraje Aluminio', 2, 'unidad'),
('EN002', 'Enchufe Cobre', 2, 'unidad');

CREATE OR REPLACE FUNCTION desactivar_precios_anteriores()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE precio_material 
    SET estado = 'Inactivo' 
    WHERE id_material = NEW.id_material 
    AND id_precio != NEW.id_precio;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_unico_precio_activo
    AFTER INSERT ON precio_material
    FOR EACH ROW
    WHEN (NEW.estado = 'Activo')
    EXECUTE FUNCTION desactivar_precios_anteriores();

INSERT INTO precio_material (id_material, precio) VALUES
(1, 2200.00), (2, 1900.00), (3, 2700.00), (4, 1700.00), (5, 2500.00),
(6, 2000.00), (7, 1400.00), (8, 2400.00), (9, 2100.00), (10, 1000.00),
(11, 1300.00), (12, 900.00), (13, 3200.00), (14, 1600.00), (15, 2700.00),
(16, 1800.00), (17, 1900.00), (18, 1700.00), (19, 2200.00), (20, 1500.00),
(21, 2800.00), (22, 3200.00), (23, 1600.00), (24, 1400.00), (25, 1200.00),
(26, 3500.00), (27, 2000.00), (28, 3800.00), (29, 4200.00), (30, 2900.00),
(31, 8500.00), (32, 9200.00), (33, 4800.00), (34, 12000.00), (35, 15000.00),
(36, 18000.00), (37, 22000.00), (38, 28000.00), (39, 3500.00), (40, 4200.00),
(41, 3800.00), (42, 25000.00), (43, 12000.00), (44, 8500.00), (45, 5200.00);

INSERT INTO precio_material (id_material, precio, estado) VALUES
(1, 2000.00, 'Inactivo'), (1, 2100.00, 'Inactivo'),
(2, 1700.00, 'Inactivo'), (2, 1800.00, 'Inactivo'),
(3, 2500.00, 'Inactivo'), (3, 2600.00, 'Inactivo'),
(4, 1500.00, 'Inactivo'), (4, 1600.00, 'Inactivo'),
(5, 2300.00, 'Inactivo'), (5, 2400.00, 'Inactivo');

INSERT INTO pedido (fecha_retiro, nombre_persona, ciudad, calle, altura, estado, observaciones) VALUES
('2024-01-15 10:00:00', 'Juan Pérez', 'Córdoba', 'Av. Colón', '1200', 'Completado', 'Retiro por la mañana'),
('2024-01-16 14:30:00', 'María García', 'Córdoba', 'Av. Vélez Sarsfield', '850', 'Pendiente', 'Material seco y limpio'),
('2024-01-17 09:15:00', 'Carlos López', 'Carlos Paz', 'San Martín', '450', 'Completado', 'Urgente para fundición'),
('2024-01-18 16:00:00', 'Ana Martínez', 'Córdoba', 'Bv. San Juan', '2300', 'En Proceso', 'Separado por tipo'),
('2024-01-19 11:30:00', 'Roberto Díaz', 'Alta Gracia', 'Sarmiento', '670', 'Cancelado', 'Cliente no se presentó'),
('2024-01-20 08:45:00', 'Laura Fernández', 'Córdoba', 'Av. Rafael Núñez', '3800', 'Completado', 'Pago en efectivo'),
('2024-01-21 13:20:00', 'Diego Silva', 'Córdoba', 'La Rioja', '1250', 'Pendiente', 'Gran volumen de cobre'),
('2024-01-22 10:10:00', 'Sofía Romero', 'Villa Allende', 'Av. Chacabuco', '890', 'En Proceso', 'Material industrial'),
('2024-01-23 15:45:00', 'Miguel Torres', 'Córdoba', 'Av. Fuerza Aérea', '4200', 'Completado', 'Retiro con camión'),
('2024-01-24 12:00:00', 'Elena Castro', 'Córdoba', 'Av. Cruz Roja', '2100', 'Pendiente', 'Baterías automotrices'),
('2024-01-25 09:30:00', 'Jorge Molina', 'Córdoba', 'Av. Richieri', '3500', 'Completado', 'Aluminio de construcción'),
('2024-01-26 14:15:00', 'Patricia Ruiz', 'Córdoba', 'Av. Valparaíso', '1800', 'En Proceso', 'Material mixto'),
('2024-01-27 11:00:00', 'Fernando Herrera', 'Córdoba', 'Av. Japón', '2900', 'Pendiente', 'Radiadores varios'),
('2024-01-28 16:30:00', 'Gabriela Ortiz', 'Córdoba', 'Av. Agustín Tosco', '1500', 'Completado', 'Cobre de alta pureza'),
('2024-01-29 10:45:00', 'Luis Suárez', 'Córdoba', 'Av. Circunvalación', '4800', 'Cancelado', 'Cambio de fecha');

INSERT INTO detalle_pedido (id_pedido, id_material, cantidad, precio_unitario, subtotal) VALUES
(1, 3, 50.5, 2700.00, 136350.00),
(1, 7, 25.0, 1400.00, 35000.00),
(1, 12, 15.2, 900.00, 13680.00),
(2, 5, 30.0, 2500.00, 75000.00),
(2, 9, 18.7, 2100.00, 39270.00),
(2, 14, 22.3, 1600.00, 35680.00),
(3, 1, 45.8, 2200.00, 100760.00),
(3, 8, 32.1, 2400.00, 77040.00),
(3, 11, 12.5, 1300.00, 16250.00),
(4, 4, 28.6, 1700.00, 48620.00),
(4, 10, 35.2, 1000.00, 35200.00),
(4, 13, 8.9, 3200.00, 28480.00),
(5, 2, 40.0, 1900.00, 76000.00),
(5, 6, 27.3, 2000.00, 54600.00),
(5, 15, 19.8, 2700.00, 53460.00),
(6, 16, 55.7, 1800.00, 100260.00),
(6, 22, 31.4, 3200.00, 100480.00),
(6, 28, 24.1, 3800.00, 91580.00),
(7, 17, 38.9, 1900.00, 73910.00),
(7, 23, 26.5, 1600.00, 42400.00),
(7, 29, 19.7, 4200.00, 82740.00),
(8, 31, 5.0, 8500.00, 42500.00),
(8, 35, 3.0, 15000.00, 45000.00),
(8, 39, 8.0, 3500.00, 28000.00),
(9, 32, 4.0, 9200.00, 36800.00),
(9, 36, 2.0, 18000.00, 36000.00),
(9, 40, 6.0, 4200.00, 25200.00),
(10, 18, 47.5, 1700.00, 80750.00),
(10, 24, 30.1, 1400.00, 42140.00),
(10, 33, 7.0, 4800.00, 33600.00),
(11, 19, 60.2, 2200.00, 132440.00),
(11, 25, 28.7, 1200.00, 34440.00),
(11, 34, 4.0, 12000.00, 48000.00),
(12, 20, 42.8, 1500.00, 64200.00),
(12, 26, 24.3, 3500.00, 85050.00),
(12, 37, 3.0, 22000.00, 66000.00),
(13, 21, 58.9, 2800.00, 164920.00),
(13, 27, 34.5, 2000.00, 69000.00),
(13, 38, 2.0, 28000.00, 56000.00),
(14, 30, 36.4, 2900.00, 105560.00),
(14, 41, 38.7, 3800.00, 147060.00),
(14, 44, 5.0, 8500.00, 42500.00),
(15, 42, 44.2, 25000.00, 1105000.00),
(15, 43, 32.8, 12000.00, 393600.00),
(15, 45, 21.4, 5200.00, 111280.00);

CREATE OR REPLACE VIEW vista_materiales_precios AS
SELECT 
    m.id_material,
    m.codigo,
    m.nombre,
    c.nombre as categoria,
    m.unidad_medida,
    pm.precio as precio_actual,
    pm.fecha_actualizacion
FROM material m
JOIN categoria c ON m.id_categoria = c.id_categoria
JOIN precio_material pm ON m.id_material = pm.id_material
WHERE pm.estado = 'Activo';

CREATE OR REPLACE VIEW vista_pedidos_completos AS
SELECT 
    p.id_pedido,
    p.fecha_creacion,
    p.fecha_retiro,
    p.nombre_persona,
    p.ciudad,
    p.calle,
    p.altura,
    p.estado,
    p.observaciones,
    COUNT(dp.id_detalle) as cantidad_materiales,
    COALESCE(SUM(dp.subtotal), 0) as total_pedido
FROM pedido p
LEFT JOIN detalle_pedido dp ON p.id_pedido = dp.id_pedido
GROUP BY p.id_pedido;

CREATE OR REPLACE FUNCTION obtener_precio_actual(id_material_param INTEGER)
RETURNS DECIMAL AS $$
DECLARE
    precio_actual DECIMAL;
BEGIN
    SELECT precio INTO precio_actual
    FROM precio_material
    WHERE id_material = id_material_param
    AND estado = 'Activo'
    ORDER BY fecha_actualizacion DESC
    LIMIT 1;
    
    IF precio_actual IS NULL THEN
        RAISE EXCEPTION 'Material ID % no tiene precio activo definido', id_material_param;
    END IF;
    
    RETURN precio_actual;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION actualizar_precio_material(
    p_id_material INTEGER,
    p_nuevo_precio DECIMAL
) RETURNS VOID AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM material WHERE id_material = p_id_material) THEN
        RAISE EXCEPTION 'Material ID % no existe', p_id_material;
    END IF;
    
    IF p_nuevo_precio <= 0 THEN
        RAISE EXCEPTION 'El precio debe ser mayor a cero';
    END IF;
    
    INSERT INTO precio_material (id_material, precio)
    VALUES (p_id_material, p_nuevo_precio);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION crear_pedido(
    p_fecha_retiro TIMESTAMP,
    p_nombre_persona VARCHAR(100),
    p_ciudad VARCHAR(100),
    p_calle VARCHAR(150),
    p_altura VARCHAR(20),
    p_observaciones TEXT DEFAULT NULL
) RETURNS INTEGER AS $$
DECLARE
    nuevo_id INTEGER;
BEGIN
    INSERT INTO pedido (fecha_retiro, nombre_persona, ciudad, calle, altura, observaciones)
    VALUES (p_fecha_retiro, p_nombre_persona, p_ciudad, p_calle, p_altura, p_observaciones)
    RETURNING id_pedido INTO nuevo_id;
    
    RETURN nuevo_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION agregar_material_pedido(
    p_id_pedido INTEGER,
    p_id_material INTEGER,
    p_cantidad DECIMAL
) RETURNS VOID AS $$
DECLARE
    v_precio_unitario DECIMAL;
    v_subtotal DECIMAL;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pedido WHERE id_pedido = p_id_pedido) THEN
        RAISE EXCEPTION 'Pedido ID % no existe', p_id_pedido;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM material WHERE id_material = p_id_material) THEN
        RAISE EXCEPTION 'Material ID % no existe', p_id_material;
    END IF;
    
    IF p_cantidad <= 0 THEN
        RAISE EXCEPTION 'La cantidad debe ser mayor a cero';
    END IF;
    
    v_precio_unitario := obtener_precio_actual(p_id_material);
    v_subtotal := p_cantidad * v_precio_unitario;
    
    INSERT INTO detalle_pedido (id_pedido, id_material, cantidad, precio_unitario, subtotal)
    VALUES (p_id_pedido, p_id_material, p_cantidad, v_precio_unitario, v_subtotal);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE cambiar_precio_material(
    p_id_material INTEGER,
    p_nuevo_precio DECIMAL
) AS $$
BEGIN
    PERFORM actualizar_precio_material(p_id_material, p_nuevo_precio);
END;
$$ LANGUAGE plpgsql;

CREATE INDEX idx_precio_material_id_fecha ON precio_material(id_material, fecha_actualizacion DESC);
CREATE INDEX idx_pedido_fecha_retiro ON pedido(fecha_retiro);
CREATE INDEX idx_pedido_estado ON pedido(estado);
CREATE INDEX idx_detalle_pedido_id ON detalle_pedido(id_pedido);
CREATE INDEX idx_material_categoria ON material(id_categoria);
CREATE INDEX idx_precio_material_estado ON precio_material(estado);

COMMENT ON TABLE categoria IS 'Almacena las categorías de materiales (Ferrosos y No Ferrosos)';
COMMENT ON TABLE material IS 'Almacena todos los materiales que se compran, con su unidad de medida';
COMMENT ON TABLE precio_material IS 'Histórico de precios de los materiales, se actualiza constantemente. Solo un precio activo por material.';
COMMENT ON TABLE pedido IS 'Registro de pedidos de compra de materiales';
COMMENT ON TABLE detalle_pedido IS 'Detalle de los materiales incluidos en cada pedido (guarda precio del momento)';
COMMENT ON COLUMN precio_material.fecha_actualizacion IS 'Fecha y hora exacta de la actualización del precio';
COMMENT ON COLUMN detalle_pedido.precio_unitario IS 'Precio al momento de crear el pedido, no cambia';
COMMENT ON COLUMN precio_material.estado IS 'Activo/Inactivo - Solo un precio activo por material garantizado por trigger';