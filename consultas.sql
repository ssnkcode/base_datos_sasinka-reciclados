-- =============================================
-- ARCHIVO COMPLETO DE CONSULTAS - SASINKA RECICLADOS
-- =============================================

-- ===================
-- COMANDOS BÁSICOS DE LA BASE DE DATOS
-- ===================

-- Crear base de datos (ejecutar primero)
-- CREATE DATABASE Sasinka_reciclados;

-- Conectar a base de datos
-- \c Sasinka_reciclados

-- Ver todas las tablas 
-- \dt

-- ===================
-- CONSULTAS DISPONIBLES - CATEGORÍAS
-- ===================

-- Ver todas las categorías
SELECT * FROM categoria;

-- Ver categorías activas
SELECT * FROM categoria WHERE estado = 'Activo';

-- Contar total de categorías
SELECT COUNT(*) as total_categorias FROM categoria;

-- ===================
-- CONSULTAS DISPONIBLES - MATERIALES
-- ===================

-- 1. Ver TODOS los materiales
SELECT * FROM material;

-- 2. Ver solo columnas específicas
SELECT codigo, nombre, unidad_medida FROM material;

-- 3. Materiales por categoría (Ferrosos)
SELECT * FROM material WHERE id_categoria = 1;

-- 4. Materiales por categoría (No Ferrosos)
SELECT * FROM material WHERE id_categoria = 2;

-- 5. Buscar material por código exacto
SELECT * FROM material WHERE codigo = 'CO001';

-- 6. Buscar materiales por nombre (parcial)
SELECT * FROM material WHERE nombre LIKE '%Aluminio%';

-- 7. Materiales activos solamente
SELECT * FROM material WHERE estado = 'Activo';

-- 8. Materiales por unidad de medida
SELECT * FROM material WHERE unidad_medida = 'kg';
SELECT * FROM material WHERE unidad_medida = 'unidad';

-- 9. Contar total de materiales
SELECT COUNT(*) as total_materiales FROM material;

-- 10. Materiales ordenados por nombre
SELECT * FROM material ORDER BY nombre;

-- 11. Materiales ordenados por código
SELECT * FROM material ORDER BY codigo;

-- 12. Materiales con su categoría
SELECT m.codigo, m.nombre, c.nombre as categoria, m.unidad_medida
FROM material m
JOIN categoria c ON m.id_categoria = c.id_categoria;

-- 13. Materiales con precio actual (usando vista)
SELECT * FROM vista_materiales_precios;

-- 14. Materiales de una categoría específica con precios
SELECT * FROM vista_materiales_precios WHERE categoria = 'No Ferroso';

-- 15. Materiales caros (precio > 10,000)
SELECT * FROM vista_materiales_precios WHERE precio_actual > 10000;

-- 16. Materiales agrupados por categoría
SELECT c.nombre as categoria, COUNT(*) as cantidad
FROM material m
JOIN categoria c ON m.id_categoria = c.id_categoria
GROUP BY c.nombre;

-- 17. Materiales que son baterías
SELECT * FROM material WHERE nombre LIKE '%Bateria%';

-- 18. Materiales con su categoría y estado
SELECT m.codigo, m.nombre, c.nombre as categoria, m.estado
FROM material m
JOIN categoria c ON m.id_categoria = c.id_categoria
WHERE m.estado = 'Activo';

-- 19. Cambiar estado de un material
UPDATE material SET estado = 'Inactivo' WHERE codigo = 'CA001';

-- 20. Cambiar unidad de medida
UPDATE material SET unidad_medida = 'unidad' WHERE codigo = 'BA001';

-- 21. Buscar materiales por categoría y estado
SELECT m.*, c.nombre as categoria_nombre
FROM material m
JOIN categoria c ON m.id_categoria = c.id_categoria
WHERE c.nombre = 'Ferroso' AND m.estado = 'Activo';

-- 22. Materiales con rango de precios
SELECT * FROM vista_materiales_precios 
WHERE precio_actual BETWEEN 1000 AND 5000;

-- 23. Materiales ordenados por precio (ascendente/descendente)
SELECT * FROM vista_materiales_precios 
ORDER BY precio_actual ASC;

SELECT * FROM vista_materiales_precios 
ORDER BY precio_actual DESC;

-- 24. Materiales más populares (con más pedidos)
SELECT m.nombre, COUNT(dp.id_detalle) as total_pedidos
FROM material m
LEFT JOIN detalle_pedido dp ON m.id_material = dp.id_material
GROUP BY m.nombre
ORDER BY total_pedidos DESC;

-- 25. Materiales sin stock o con bajo movimiento
SELECT m.*
FROM material m
LEFT JOIN detalle_pedido dp ON m.id_material = dp.id_material
WHERE dp.id_detalle IS NULL;

-- 26. Resumen de materiales por categoría y estado
SELECT 
    c.nombre as categoria,
    m.estado,
    COUNT(*) as cantidad
FROM material m
JOIN categoria c ON m.id_categoria = c.id_categoria
GROUP BY c.nombre, m.estado
ORDER BY c.nombre, m.estado;

-- 27. Verificar códigos duplicados
SELECT codigo, COUNT(*) as duplicados
FROM material
GROUP BY codigo
HAVING COUNT(*) > 1;

-- 28. Materiales sin categoría asignada
SELECT * FROM material 
WHERE id_categoria IS NULL;

-- 29. Cambiar categoría de múltiples materiales
UPDATE material 
SET id_categoria = 2 
WHERE codigo IN ('AL001', 'AL002', 'CO001');

-- 30. Reactivar materiales inactivos
UPDATE material 
SET estado = 'Activo' 
WHERE estado = 'Inactivo' AND id_categoria = 1;

-- 31. Exportar lista completa de materiales para reportes
SELECT 
    m.codigo,
    m.nombre,
    c.nombre as categoria,
    m.unidad_medida,
    m.estado,
    pm.precio as precio_actual,
    pm.fecha_actualizacion
FROM material m
JOIN categoria c ON m.id_categoria = c.id_categoria
LEFT JOIN precio_material pm ON m.id_material = pm.id_material AND pm.estado = 'Activo'
ORDER BY c.nombre, m.nombre;

-- 32. Materiales creados/modificados recientemente
SELECT * FROM material 
WHERE fecha_creacion >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY fecha_creacion DESC;

-- ===================
-- CONSULTAS DISPONIBLES - PRECIOS
-- ===================

-- Ver todos los precios
SELECT * FROM precio_material;

-- Ver precios actuales activos
SELECT * FROM precio_material WHERE estado = 'Activo';

-- Histórico de precios de un material específico
SELECT * FROM precio_material WHERE id_material = 1 ORDER BY fecha_actualizacion DESC;

-- Precios ordenados por fecha de actualización
SELECT * FROM precio_material ORDER BY fecha_actualizacion DESC;

-- Histórico de precios de un material específico con nombre
SELECT 
    m.nombre,
    pm.precio,
    pm.fecha_actualizacion
FROM precio_material pm
JOIN material m ON pm.id_material = m.id_material
WHERE m.codigo = 'CO001'
ORDER BY pm.fecha_actualizacion DESC;

-- ===================
-- CONSULTAS DISPONIBLES - PEDIDOS
-- ===================

-- Ver todos los pedidos
SELECT * FROM pedido;

-- Pedidos pendientes
SELECT * FROM pedido WHERE estado = 'Pendiente';

-- Pedidos completados
SELECT * FROM pedido WHERE estado = 'Completado';

-- Pedidos cancelados
SELECT * FROM pedido WHERE estado = 'Cancelado';

-- Pedidos por fecha de retiro
SELECT * FROM pedido WHERE fecha_retiro BETWEEN '2024-01-01' AND '2024-01-31';

-- Pedidos por ciudad
SELECT * FROM pedido WHERE ciudad = 'Córdoba';

-- Pedidos completos con vista
SELECT * FROM vista_pedidos_completos;

-- Pedidos pendientes con vista
SELECT * FROM vista_pedidos_completos WHERE estado = 'Pendiente';

-- Actualizar estado de un pedido
UPDATE pedido SET estado = 'Completado' WHERE id_pedido = 1;

-- ===================
-- CONSULTAS DISPONIBLES - DETALLES DE PEDIDOS
-- ===================

-- Ver todos los detalles de pedidos
SELECT * FROM detalle_pedido;

-- Detalles de un pedido específico
SELECT * FROM detalle_pedido WHERE id_pedido = 1;

-- Detalles con información de materiales
SELECT dp.*, m.nombre as material_nombre 
FROM detalle_pedido dp 
JOIN material m ON dp.id_material = m.id_material;

-- Detalles de un pedido específico con información completa
SELECT 
    p.id_pedido,
    p.nombre_persona,
    m.nombre as material,
    m.unidad_medida,
    dp.cantidad,
    dp.precio_unitario,
    dp.subtotal
FROM pedido p
JOIN detalle_pedido dp ON p.id_pedido = dp.id_pedido
JOIN material m ON dp.id_material = m.id_material
WHERE p.id_pedido = 1;

-- ===================
-- FUNCIONES DISPONIBLES
-- ===================

-- Obtener precio actual de un material
SELECT obtener_precio_actual(1);

-- Crear nuevo pedido
SELECT crear_pedido('2024-01-30 10:00', 'Cliente Ejemplo', 'Córdoba', 'Calle Falsa', '123', 'Observaciones');

-- Agregar material a pedido
SELECT agregar_material_pedido(1, 1, 10.5);

-- Actualizar precio manteniendo histórico
CALL cambiar_precio_material(1, 2300.00);

-- Actualizar precio de un material (usando función)
SELECT actualizar_precio_material(1, 2500.00);

-- ===================
-- CONSULTAS DE ELIMINACIÓN
-- ===================

-- Eliminar material (solo si no tiene relaciones)
DELETE FROM material WHERE id_material = 1;

-- Eliminar pedido (elimina automáticamente detalles por CASCADE)
DELETE FROM pedido WHERE id_pedido = 1;

-- Eliminar categoría (solo si no tiene materiales)
DELETE FROM categoria WHERE id_categoria = 1;

-- ===================
-- CONSULTAS DE RESUMEN Y ESTADÍSTICAS
-- ===================

-- Total de pedidos por estado
SELECT estado, COUNT(*) as total FROM pedido GROUP BY estado;

-- Total vendido por material
SELECT m.nombre, SUM(dp.cantidad) as total_cantidad, SUM(dp.subtotal) as total_ventas
FROM detalle_pedido dp
JOIN material m ON dp.id_material = m.id_material
GROUP BY m.nombre
ORDER BY total_ventas DESC;

-- Top 5 materiales más vendidos
SELECT m.nombre, SUM(dp.cantidad) as total_vendido
FROM detalle_pedido dp
JOIN material m ON dp.id_material = m.id_material
GROUP BY m.nombre
ORDER BY total_vendido DESC
LIMIT 5;

-- Ventas totales por mes
SELECT 
    EXTRACT(YEAR FROM p.fecha_creacion) as año,
    EXTRACT(MONTH FROM p.fecha_creacion) as mes,
    SUM(dp.subtotal) as ventas_totales
FROM pedido p
JOIN detalle_pedido dp ON p.id_pedido = dp.id_pedido
GROUP BY año, mes
ORDER BY año, mes;

-- ===================
-- CONSULTAS DE VALIDACIÓN
-- ===================

-- Verificar materiales sin precios activos
SELECT m.* 
FROM material m
LEFT JOIN precio_material pm ON m.id_material = pm.id_material AND pm.estado = 'Activo'
WHERE pm.id_precio IS NULL;

-- Verificar pedidos sin detalles
SELECT p.*
FROM pedido p
LEFT JOIN detalle_pedido dp ON p.id_pedido = dp.id_pedido
WHERE dp.id_detalle IS NULL;

-- Verificar categorías sin materiales
SELECT c.*
FROM categoria c
LEFT JOIN material m ON c.id_categoria = m.id_categoria
WHERE m.id_material IS NULL;

-- ===================
-- CONSULTAS DE OPTIMIZACIÓN (DDL)
-- ===================

-- Índices sugeridos para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_material_codigo ON material(codigo);
CREATE INDEX IF NOT EXISTS idx_material_categoria ON material(id_categoria);
CREATE INDEX IF NOT EXISTS idx_material_estado ON material(estado);
CREATE INDEX IF NOT EXISTS idx_material_nombre ON material(nombre);
CREATE INDEX IF NOT EXISTS idx_precio_material_estado ON precio_material(estado);
CREATE INDEX IF NOT EXISTS idx_pedido_estado ON pedido(estado);
CREATE INDEX IF NOT EXISTS idx_pedido_fecha ON pedido(fecha_creacion);
CREATE INDEX IF NOT EXISTS idx_detalle_pedido_id ON detalle_pedido(id_pedido);

-- ===================
-- CONSULTAS DE LIMPIEZA Y MANTENIMIENTO
-- ===================

-- Limpiar precios históricos antiguos (mantener solo últimos 6 meses)
DELETE FROM precio_material 
WHERE estado = 'Inactivo' 
AND fecha_actualizacion < CURRENT_DATE - INTERVAL '6 months';

-- Inactivar materiales sin movimiento en los últimos 3 meses
UPDATE material 
SET estado = 'Inactivo'
WHERE id_material NOT IN (
    SELECT DISTINCT dp.id_material 
    FROM detalle_pedido dp 
    JOIN pedido p ON dp.id_pedido = p.id_pedido 
    WHERE p.fecha_creacion >= CURRENT_DATE - INTERVAL '3 months'
);

-- ===================
-- CONSULTAS DE AUDITORÍA
-- ===================

-- Auditoría de cambios en precios
SELECT 
    m.nombre as material,
    pm.precio as precio_anterior,
    pm.fecha_actualizacion,
    c.nombre as categoria
FROM precio_material pm
JOIN material m ON pm.id_material = m.id_material
JOIN categoria c ON m.id_categoria = c.id_categoria
WHERE pm.estado = 'Inactivo'
ORDER BY pm.fecha_actualizacion DESC;

-- Resumen de actividad del sistema
SELECT 
    (SELECT COUNT(*) FROM material) as total_materiales,
    (SELECT COUNT(*) FROM material WHERE estado = 'Activo') as materiales_activos,
    (SELECT COUNT(*) FROM pedido) as total_pedidos,
    (SELECT COUNT(*) FROM pedido WHERE estado = 'Pendiente') as pedidos_pendientes,
    (SELECT COALESCE(SUM(subtotal), 0) FROM detalle_pedido) as ventas_totales;