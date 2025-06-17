# 🚀 Inventrax - Arquitectura Galaxy (Clean Architecture + MVVM + Modular)

![Inventrax Architecture Diagram](https://ramonesteban78.github.io/images/flow-mvvm-2.png)


# InvenTRAX
# Base de Datos y Estructura del Proyecto
## Tablas de la Base de Datos
# 🚀 inventrax

**Sistema avanzado de gestión de inventario en Flutter + SQLite/PostgreSQL**

---

## 🧭 Descripción General

Inventrax es una solución móvil moderna para la gestión integral de inventarios. Diseñado con **Flutter**, se enfoca en ofrecer una interfaz intuitiva, control preciso de productos, historial de movimientos, gestión de proveedores y más.

> ✅ Proyecto modular  
> ✅ Arquitectura limpia  
> ✅ Base de datos estructurada  
> ✅ Ideal para PYMEs o entornos empresariales

---
# 📄 Esquema de Tablas Final

---

## 🔐 usuarios
- `id_usuario` (PK)
- `nombre`
- `apellido`
- `correo_electronico`
- `contraseña`
- `created_at`
- `documento_identidad`
- `telefono`

---

## 🗂️ categorias
- `id_categoria` (PK)
- `nombre_categoria`
- `created_at`

---

## 🏢 proveedores
- `id_proveedor` (PK)
- `nombre_proveedor`
- `telefono`
- `correo`
- `direccion`
- `created_at`

---

## 📦 productos
- `id_producto` (PK)
- `nombre_producto`
- `descripcion`
- `cantidad_disponible`
- `unidad_medida`
- `precio_unitario`
- `id_categoria` (FK → categorias.id_categoria)
- `codigo_barras`
- `created_at`

---

## 📥 entradas_producto
- `id_entrada` (PK)
- `id_producto` (FK → productos.id_producto)
- `id_proveedor` (FK → proveedores.id_proveedor)
- `cantidad`
- `fecha_entrada`
- `precio_compra`
- `created_at`

---

## 🔁 movimientos_inventario
- `id_movimiento` (PK)
- `id_producto` (FK → productos.id_producto)
- `id_usuario` (FK → usuarios.id_usuario)
- `tipo_movimiento` (entrada / salida / ajuste)
- `cantidad`
- `fecha_movimiento`
- `motivo`
- `destinatario`
- `created_at`

---

## 👥 clientes
- `id_cliente` (PK)
- `tipo_cliente` (persona / empresa)
- `nombre`
- `apellido` (solo para persona)
- `razon_social` (solo para empresa)
- `documento_identidad` (único: DNI o RUC)
- `telefono`
- `correo`
- `direccion`
- `created_at`

---

## 🧾 ventas
- `id_venta` (PK)
- `id_cliente` (FK → clientes.id_cliente)
- `id_usuario` (FK → usuarios.id_usuario)
- `fecha_venta`
- `total`
- `estado` (pagado / pendiente / cancelado)
- `created_at`

---

## 📑 detalle_ventas
- `id_detalle` (PK)
- `id_venta` (FK → ventas.id_venta)
- `id_producto` (FK → productos.id_producto)
- `cantidad`
- `precio_unitario`
- `subtotal`

---

## 📁 Estructura del Proyecto Flutter
# 🔐 usuarios

| id_usuario | nombre | apellido | correo_electronico    | contraseña | documento_identidad | telefono    | created_at          | id_rol |
|------------|--------|----------|------------------------|------------|----------------------|-------------|---------------------|--------|
| 1          | Marco  | Ruiz     | marco@correo.com       | 123456     | 12345678             | 987654321   | 2025-05-22 10:00    | 1      |
| 2          | Laura  | Gomez    | laura@correo.com       | abcdef     | 87654321             | 912345678   | 2025-05-22 10:01    | 2      |

---

# 🔐 roles

| id_rol | nombre        | created_at          |
|--------|---------------|---------------------|
| 1      | Administrador | 2025-06-01 10:00:00 |
| 2      | Usuario       | 2025-06-01 10:05:00 |
| 3      | Invitado      | 2025-06-01 10:10:00 |



# 🗂️ categorias

| id_categoria | nombre_categoria | created_at          |
|--------------|------------------|---------------------|
| 1            | Electrónica      | 2025-05-22 10:00    |
| 2            | Ropa             | 2025-05-22 10:01    |

---

# 🏢 proveedores

| id_proveedor | nombre_proveedor | telefono  | correo            | direccion         | created_at          |
|--------------|------------------|-----------|-------------------|-------------------|---------------------|
| 1            | Proveedor Tech   | 987654321 | contacto@tech.com | Av. Tecnológica 100| 2025-05-22 10:02    |
| 2            | Moda Perú        | 912345678 | ventas@modaperu.com | Calle Estilo 45  | 2025-05-22 10:03    |

---

# 📦 productos

| id_producto | nombre_producto | descripcion           | cantidad_disponible | unidad_medida | precio_venta | id_categoria | codigo_barras  | created_at          |
|-------------|-----------------|-----------------------|---------------------|---------------|--------------|--------------|----------------|---------------------|
| 1           | Laptop Lenovo   | Laptop de 15 pulgadas | 10                  | unidad        | 2500.00      | 1            | 1234567890123  | 2025-05-22 10:04    |
| 2           | Polo Blanco     | Polo de algodón talla M| 50                  | unidad        | 35.00        | 2            | 9876543210987  | 2025-05-22 10:05    |

---

# 📥 entradas_producto

| id_entrada | id_producto | id_proveedor | cantidad | fecha_entrada | precio_compra | created_at          |
|------------|-------------|--------------|----------|---------------|--------------|---------------------|
| 1          | 1           | 1            | 10       | 2025-05-20    | 2000.00      | 2025-05-22 10:06    |
| 2          | 2           | 2            | 50       | 2025-05-19    | 25.00        | 2025-05-22 10:07    |

---

# 🔁 movimientos_inventario

| id_movimiento | id_producto | id_usuario | tipo_movimiento | cantidad | fecha_movimiento | motivo          | destinatario     | created_at          |
|---------------|-------------|------------|-----------------|----------|------------------|-----------------|------------------|---------------------|
| 1             | 1           | 1          | entrada         | 10       | 2025-05-20       | Stock inicial   | Almacén Central  | 2025-05-22 10:08    |
| 2             | 2           | 2          | entrada         | 50       | 2025-05-19       | Compra a proveedor | Tienda A       | 2025-05-22 10:09    |

---

# 👥 clientes

| id_cliente | tipo_cliente | nombre  | apellido | razon_social       | documento_identidad | telefono   | correo             | direccion           | created_at          |
|------------|--------------|---------|----------|--------------------|---------------------|------------|--------------------|---------------------|---------------------|
| 1          | persona      | Juan    | Pérez    | NULL               | 12345678            | 987111222  | juan@gmail.com     | Av. Siempre Viva 742 | 2025-05-22 10:10    |
| 2          | empresa      | Distribuidora | NULL | Distribuidora SAC  | 20123456789          | 954444555  | empresa@correo.com | Calle Comercio 303  | 2025-05-22 10:11    |

---

# 🧾 ventas

| id_venta | id_cliente | id_usuario | fecha_venta | total  | estado    | created_at          |
|----------|------------|------------|-------------|--------|-----------|---------------------|
| 1        | 1          | 1          | 2025-05-21  | 2550.00| pagado    | 2025-05-22 10:12    |
| 2        | 2          | 2          | 2025-05-21  | 1400.00| pendiente | 2025-05-22 10:13    |

---

# 📑 detalle_ventas

| id_detalle | id_venta | id_producto | cantidad | precio_unitario | subtotal  |
|------------|----------|-------------|----------|-----------------|-----------|
| 1          | 1        | 1           | 1        | 2500.00         | 2500.00   |
| 2          | 1        | 2           | 1        | 50.00           | 50.00     |
| 3          | 2        | 2           | 40       | 35.00           | 1400.00   |


## 🌌 Estructura Cósmica del Proyecto

```bash
lib/
│
├── models/                   
│   ├── usuario.dart          
│   ├── categoria.dart        
│   ├── proveedor.dart        
│   ├── producto.dart         
│   ├── entrada_producto.dart 
│   ├── movimiento_inventario.dart 
│   ├── cliente.dart                # Nuevo: clase Cliente
│   ├── venta.dart                  # Nuevo: clase Venta
│   └── detalle_venta.dart          # Nuevo: clase DetalleVenta
│
├── viewmodels/               
│   ├── auth_viewmodel.dart
│   ├── categoria_viewmodel.dart
│   ├── proveedor_viewmodel.dart
│   ├── producto_viewmodel.dart
│   ├── entrada_producto_viewmodel.dart
│   ├── movimiento_inventario_viewmodel.dart
│   ├── cliente_viewmodel.dart          # Nuevo
│   ├── venta_viewmodel.dart            # Nuevo
│   └── detalle_venta_viewmodel.dart    # Nuevo
│
├── repositories/             
│   ├── usuario_repository.dart
│   ├── categoria_repository.dart
│   ├── proveedor_repository.dart
│   ├── producto_repository.dart
│   ├── entrada_producto_repository.dart
│   ├── movimiento_inventario_repository.dart
│   ├── cliente_repository.dart          # Nuevo
│   ├── venta_repository.dart            # Nuevo
│   └── detalle_venta_repository.dart    # Nuevo
│
├── views/                    
│   ├── usuarios/             
│   ├── categorias/
│   ├── proveedores/
│   ├── productos/
│   ├── entradas_producto/
│   ├── movimientos_inventario/
│   ├── clientes/                      # Nuevo: screens/widgets clientes
│   ├── ventas/                       # Nuevo: screens/widgets ventas
│   └── detalle_ventas/               # Nuevo: screens/widgets detalle ventas (opcional, si lo necesitas separado)
│
├── widgets/                  
│
├── utils/                    
│
└── main.dart                 
--------------------
├── views/
│
│   ├── usuarios_auth/                   # Autenticación de usuarios
│   │   ├── login_screen.dart            # Pantalla para iniciar sesión
│   │   ├── register_screen.dart         # Pantalla para registrar usuario
│   │   └── recovery_screen.dart         # Recuperación de contraseña
│
│   ├── clientes/                        # Gestión de clientes
│   │   ├── clientes_list.dart           # Lista de clientes
│   │   ├── clientes_form.dart           # Crear/editar cliente
│   │   └── cliente_widget.dart          # Widget reutilizable
│
│   ├── ventas/                          # Gestión de ventas
│   │   ├── ventas_list.dart             # Listado de ventas
│   │   ├── ventas_form.dart             # Registrar nueva venta
│   │   └── venta_widget.dart            # Widget de visualización
│
│   ├── detalle_ventas/                 # Detalle por venta
│   │   ├── detalle_venta_screen.dart    # Vista del detalle
│   │   └── detalle_venta_item.dart      # Widget individual
│
│   ├── productos/                       # Gestión de productos
│   │   ├── productos_list.dart
│   │   ├── productos_form.dart
│   │   └── producto_widget.dart
│
│   ├── categorias/                      # Categorías de productos
│   │   ├── categorias_list.dart
│   │   ├── categorias_form.dart
│   │   └── categoria_widget.dart
│
│   ├── proveedores/                     # Gestión de proveedores
│   │   ├── proveedores_list.dart
│   │   ├── proveedores_form.dart
│   │   └── proveedor_widget.dart
│
│   ├── entradas_producto/              # Entradas al inventario
│   │   ├── entradas_list.dart
│   │   ├── entradas_form.dart
│   │   └── entrada_widget.dart
│
│   ├── movimientos_inventario/         # Kardex o movimientos
│   │   ├── movimientos_list.dart
│   │   └── movimiento_widget.dart
│
│   └── widgets_generales/              # Widgets reutilizables
│       ├── loading_widget.dart
│       ├── custom_button.dart
│       └── empty_state.dart
