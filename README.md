

# ♻️ Sistema de Gestión de Pedidos - SASINKA RECICLADOS

## 🎯 Objetivo Principal
Digitalizar el proceso de compra de materiales de reciclaje con control estricto e historial de precios para garantizar transparencia y precisión financiera.

## 🧱 Estructura y Componentes Clave

### Tablas Principales (5)
- **categoria**: Categorías de materiales (Ferrosos, No Ferrosos, etc.)
- **material**: Materiales reciclables con códigos únicos
- **precio_material**: Historial de precios con un único precio activo
- **pedido**: Registro de pedidos de compra
- **detalle_pedido**: Detalles de materiales por pedido

### Datos Incluidos
- **15 categorías** de materiales
- **45 materiales** con precios actualizados
- **15 pedidos** con detalles completos
- **Precios históricos** para seguimiento

### Funcionalidades Avanzadas
- **2 Vistas**: `vista_materiales_precios`, `vista_pedidos_completos`
- **6 Funciones/Procedimientos**: Gestión de precios y pedidos
- **1 Trigger**: `trg_unico_precio_activo` para integridad de precios
- **6 Índices**: Optimización de consultas frecuentes

## 🛡️ Características de Integridad
- **Trigger único**: Garantiza un solo precio activo por material
- **Foreign Keys**: Relaciones referenciales estrictas
- **Constraints**: Validación de precios positivos y cantidades
- **Normalización**: Cumple 1FN, 2FN y 3FN

## 🚀 Instalación Rápida
```sql
CREATE DATABASE sasinka_reciclados;
\c sasinka_reciclados
-- Copiar y pegar todo el código SQL del repositorio
```