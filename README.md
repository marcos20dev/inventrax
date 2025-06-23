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

| id_usuario                           | nombre       | apellido        | documento_identidad | telefono  | correo_electronico             | created_at                    | id_roles |
| ------------------------------------ | ------------ | --------------- | ------------------- | --------- | ------------------------------ | ----------------------------- | -------- |
| c5ead8ec-bd66-4d9f-81a1-2399ed4fb3c9 | Marcos       | Ruiz            | 61707061            | 938788903 | mr@gmail.com                   | 2025-05-24 00:36:58.230959+00 | 9        |
| 90381c91-25a0-491e-a50d-378c045529c6 | Pedro Miguel | Garcia Gonzalez | 71045066            | 962415167 | miguelgonzalez165840@gmail.com | 2025-06-09 20:59:33.041484+00 | 6        |
---

# 🔐 roles

| id_roles | nombre            | created_at                 |
| -------- | ----------------- | -------------------------- |
| 4        | Gerente de ventas | 2025-06-16 15:50:50.6+00   |
| 6        | Vendedor          | 2025-06-16 16:42:25.164+00 |
| 7        | Editor            | 2025-06-16 16:42:30.941+00 |
| 8        | Jefe              | 2025-06-16 16:42:41.157+00 |
| 9        | Super admin       | 2025-06-16 18:49:22.585+00 |
| 10       | Miguel Garcia     | 2025-06-18 12:22:24.925+00 |


# 🗂️ categorias

| id_categoria | nombre_categoria     | created_at                    |
| ------------ | -------------------- | ----------------------------- |
| 6            | Almacenamiento       | 2025-05-28 05:58:22.736968+00 |
| 9            | Dispositivos Móviles | 2025-05-30 18:18:25.101327+00 |
| 4            | Computadoras         | 2025-05-28 04:16:54.06031+00  |
| 12           | Auriculares          | 2025-06-09 07:15:24.810045+00 |
| 13           | Periféricos          | 2025-06-10 20:23:21.710823+00 |
---

# 🏢 proveedores

| id_proveedor | nombre_proveedor      | telefono  | correo                        | direccion              | created_at                    |
| ------------ | --------------------- | --------- | ----------------------------- | ---------------------- | ----------------------------- |
| 1            | Red Perú Solutions    | 933221100 | info@redperusolutions.com     | Jr. Red 987            | 2025-05-28 23:33:54.026157+00 |
| 4            | NovaTec Peruana       | 944332211 | contacto@novatecperu.com      | Calle Nueva 654        | 2025-05-29 00:05:28.603605+00 |
| 31           | Perú Digital Services | 912345678 | info@perudigital.com          | Calle Digital 456      | 2025-06-09 04:05:06.822089+00 |
| 33           | Perú Digital Trujillo | 912345432 | info@perudigital_Trujillo.com | Calle Husares de Junin | 2025-06-09 21:11:45.076139+00 |
| 11           | InkaData Tech         | 998877665 | soporte@inkadata.com          | Jr. Datos 789          | 2025-05-29 00:14:56.309996+00 |
---


# 📦 productos

| id_producto | nombre_producto               | descripcion   | cantidad_disponible | unidad_medida | precio_venta | id_categoria | codigo_barras  | created_at                    |
| ----------- | ----------------------------- | ------------- | ------------------- | ------------- | ------------ | ------------ | -------------- | ----------------------------- |
| 32          | Sony con cancelacion de ruido | asdfdsf       | 48                  | unidad        | 20           | 12           | 5454655655212  | 2025-06-18 04:59:28.083195+00 |
| 33          | celular movistar              | asdfsdfasdf   | 15                  | unidad        | 250          | 9            | 5453543132     | 2025-06-18 17:45:42.120328+00 |
| 34          | cable usb                     | fdasdasasdffd | 20                  | unidad        | 25           | 13           | 651321987963   | 2025-06-18 17:46:21.879571+00 |
| 35          | cable tipo c                  | dasfsdfasdf   | 50                  | unidad        | 12           | 13           | 898585335522   | 2025-06-18 17:46:46.781383+00 |
| 36          | cable micro usb               | sdfasdfadsf   | 20                  | unidad        | 15           | 13           | 65465431321321 | 2025-06-18 17:48:20.769053+00 |
---

# 📥 entradas_producto

| id_entrada | id_producto | id_proveedor | cantidad | fecha_entrada              | created_at                    | precio_compra |
| ---------- | ----------- | ------------ | -------- | -------------------------- | ----------------------------- | ------------- |
| 24         | 32          | 1            | 50       | 2025-06-17 23:59:27.155+00 | 2025-06-18 04:59:28.584733+00 | 15            |
| 31         | 33          | 1            | 15       | 2025-06-18 12:45:40.701+00 | 2025-06-18 17:45:42.833449+00 | 200           |
| 32         | 34          | 4            | 20       | 2025-06-18 12:46:20.941+00 | 2025-06-18 17:46:22.187845+00 | 20            |
| 33         | 35          | 11           | 50       | 2025-06-18 12:46:46.014+00 | 2025-06-18 17:46:47.071784+00 | 10            |
| 34         | 36          | 33           | 20       | 2025-06-18 12:48:19.779+00 | 2025-06-18 17:48:21.560056+00 | 10            |
---

# 🔁 movimientos_inventario

| id_movimiento | id_producto | tipo_movimiento | cantidad | fecha_movimiento           | motivo        | destinatario    | created_at                    | id_usuario                           |
| ------------- | ----------- | --------------- | -------- | -------------------------- | ------------- | --------------- | ----------------------------- | ------------------------------------ |
| 52            | 33          | entrada         | 15       | 2025-06-18T12:45:40.701    | Stock inicial | Almacén Central | 2025-06-18 17:45:43.158762+00 | c5ead8ec-bd66-4d9f-81a1-2399ed4fb3c9 |
| 53            | 34          | entrada         | 20       | 2025-06-18T12:46:20.941    | Stock inicial | Almacén Central | 2025-06-18 17:46:22.484266+00 | c5ead8ec-bd66-4d9f-81a1-2399ed4fb3c9 |
| 42            | 32          | entrada         | 50       | 2025-06-17T23:59:27.155    | Stock inicial | Almacén Central | 2025-06-18 04:59:28.965971+00 | c5ead8ec-bd66-4d9f-81a1-2399ed4fb3c9 |
| 43            | 32          | venta           | 2        | 2025-06-17 23:59:44.992+00 | venta         | cliente         | 2025-06-18 05:00:06.960782+00 | c5ead8ec-bd66-4d9f-81a1-2399ed4fb3c9 |
| 54            | 35          | entrada         | 50       | 2025-06-18T12:46:46.014    | Stock inicial | Almacén Central | 2025-06-18 17:46:47.361339+00 | c5ead8ec-bd66-4d9f-81a1-2399ed4fb3c9 |
| 55            | 36          | entrada         | 20       | 2025-06-18T12:48:19.779    | Stock inicial | Almacén Central | 2025-06-18 17:48:21.823465+00 | c5ead8ec-bd66-4d9f-81a1-2399ed4fb3c9 |
---

# 👥 clientes

| id_cliente | tipo_cliente | nombre                                   | apellido           | razon_social | documento_identidad | telefono  | correo                        | direccion                        | created_at                    |
| ---------- | ------------ | ---------------------------------------- | ------------------ | ------------ | ------------------- | --------- | ----------------------------- | -------------------------------- | ----------------------------- |
| 19         | persona      | Lizeth                                   | Olivares Tandaypan | null         | 72463726            | 972516174 | lizeth45ymarcos@gmail.com     | Cahuide 456 - La esperanza       | 2025-06-09 21:02:26.645795+00 |
| 18         | empresa      | Cherry                                   | null               | Cherry SAC   | 80616465356         | 938788903 | cherry3456@gmailm.com         | Av. Bolognesi 353                | 2025-06-09 17:12:40.733793+00 |
| 17         | persona      | Marcos                                   | Ruiz               | null         | 61707061            | 938788903 | mrruizta@gmail.com            | Av. Tadeo Monagas 343            | 2025-06-09 17:11:52.303892+00 |
| 26         | persona      | Pedro Miguel                             | Garcia Gonzalez    | null         | 71045066            | 962415167 | miguelgonzalez16_25@gmail.com | Tadeo Monagas#880 - La esperanza | 2025-06-10 19:58:17.687925+00 |
| 27         | empresa      | Gobierno Regional de La Libertad         | null               |              | 20440374248         | 984627134 | gobierno_regional23@gmail.com | Av. España 1800,Trujillo - Perú  | 2025-06-10 20:41:44.098829+00 |
| 28         | empresa      | Instituto Nacional de Innovación Agraria | null               |              | 20131365994         | 946788451 | innovación25@gmail.com        | Av. Husares de Junin 353         | 2025-06-10 20:50:49.130054+00 |
| 29         | persona      | Rafael                                   | Lopez Alcántara    | null         | 74604512            | 962417894 | rafaelito-3@gmail.com         | Av. Cassinelli 245               | 2025-06-10 21:00:21.481282+00 |
| 30         | persona      | Esther Micaela                           | Gonzalez Marquina  | null         | 18190560            | 964286488 | esthergonzalez1819@gmail.com  | Tadeo Monagas #876               | 2025-06-11 00:01:53.272044+00 |
---

# 🧾 ventas

| id_venta | id_cliente | fecha_venta                   | total | estado | created_at                    | id_ususario                          |
| -------- | ---------- | ----------------------------- | ----- | ------ | ----------------------------- | ------------------------------------ |
| 11       | 26         | 2025-06-10 15:24:22.641412+00 | 51.0  | pagado | 2025-06-10 20:24:51.165987+00 | 90381c91-25a0-491e-a50d-378c045529c6 |
| 12       | 26         | 2025-06-10 16:05:26.439324+00 | 46.0  | pagado | 2025-06-10 21:06:19.307409+00 | 90381c91-25a0-491e-a50d-378c045529c6 |
| 13       | 17         | 2025-06-17 23:12:39.768+00    | 720   | pagado | 2025-06-18 04:14:40.886096+00 | c5ead8ec-bd66-4d9f-81a1-2399ed4fb3c9 |
| 14       | 17         | 2025-06-17 23:19:32.627+00    | 40    | pagado | 2025-06-18 04:20:04.706566+00 | c5ead8ec-bd66-4d9f-81a1-2399ed4fb3c9 |
| 15       | 17         | 2025-06-17 23:22:09.236+00    | 27000 | pagado | 2025-06-18 04:22:45.856353+00 | c5ead8ec-bd66-4d9f-81a1-2399ed4fb3c9 |
| 16       | 17         | 2025-06-17 23:33:53.308+00    | 306   | pagado | 2025-06-18 04:34:37.732053+00 | c5ead8ec-bd66-4d9f-81a1-2399ed4fb3c9 |
| 17       | 17         | 2025-06-17 23:33:53.308+00    | 1440  | pagado | 2025-06-18 04:35:14.396832+00 | c5ead8ec-bd66-4d9f-81a1-2399ed4fb3c9 |
| 18       | 30         | 2025-06-17 23:47:33.248+00    | 240   | pagado | 2025-06-18 04:47:56.423112+00 | c5ead8ec-bd66-4d9f-81a1-2399ed4fb3c9 |
| 19       | 30         | 2025-06-17 23:59:44.992+00    | 40    | pagado | 2025-06-18 05:00:06.960782+00 | c5ead8ec-bd66-4d9f-81a1-2399ed4fb3c9 |
| 20       | 30         | 2025-06-18 00:00:21.224+00    | 20    | pagado | 2025-06-18 05:00:34.582123+00 | c5ead8ec-bd66-4d9f-81a1-2399ed4fb3c9 |
| 21       | 29         | 2025-06-18 00:00:55.96+00     | 600   | pagado | 2025-06-18 05:01:32.912976+00 | c5ead8ec-bd66-4d9f-81a1-2399ed4fb3c9 |
---

# 📑 detalle_ventas

| id_detalle | id_venta | id_producto | cantidad | precio_unitario | subtotal | created_at                    |
| ---------- | -------- | ----------- | -------- | --------------- | -------- | ----------------------------- |
| 20         | 19       | 32          | 2        | 20              | 40       | 2025-06-18 05:00:06.960782+00 |
| 23         | 22       | 32          | 1        | 20              | 20       | 2025-06-18 17:51:05.319995+00 |
---

# 📑 permisos
| id_permisos | nombre                   | modulo                | created_at                    |
| ----------- | ------------------------ | --------------------- | ----------------------------- |
| 10          | Usuarios                 | Administración        | 2025-06-16 22:29:42.513189+00 |
| 11          | Ajustes del sistema      | Configuración         | 2025-06-16 22:29:42.513189+00 |
| 4           | Entradas                 | Gestión de Inventario | 2025-06-16 22:29:42.513189+00 |
| 5           | Salidas                  | Gestión de Inventario | 2025-06-16 22:29:42.513189+00 |
| 2           | Detalle de Ventas        | Gestión Comercial     | 2025-06-16 22:29:42.513189+00 |
| 3           | Clientes                 | Gestión Comercial     | 2025-06-16 22:29:42.513189+00 |
| 6           | Productos                | Productos / Entradas  | 2025-06-16 22:29:42.513189+00 |
| 7           | Categorías               | Productos / Entradas  | 2025-06-16 22:29:42.513189+00 |
| 8           | Proveedores - Listado    | Administración        | 2025-06-16 22:29:42.513189+00 |
| 9           | Gestión de Roles         | Administración        | 2025-06-16 22:29:42.513189+00 |
| 12          | Usuarios (Configuración) | Configuración         | 2025-06-16 22:29:42.513189+00 |
| 13          | Ayuda y soporte          | Configuración         | 2025-06-16 22:29:42.513189+00 |
| 1           | Registro de Ventas       | Gestión Comercial     | 2025-06-16 22:29:42.513189+00 |
---


# 📑 rol_permisos
| id_rol_permisos | rol_id | id_permisos | estado | created_at                    |
| --------------- | ------ | ----------- | ------ | ----------------------------- |
| 352             | 9      | 10          | true   | 2025-06-18 04:02:41.876563+00 |
| 353             | 9      | 11          | true   | 2025-06-18 04:02:41.876563+00 |
| 354             | 9      | 2           | true   | 2025-06-18 04:02:41.876563+00 |
| 355             | 9      | 3           | true   | 2025-06-18 04:02:41.876563+00 |
| 356             | 9      | 6           | true   | 2025-06-18 04:02:41.876563+00 |
| 357             | 9      | 7           | true   | 2025-06-18 04:02:41.876563+00 |
| 358             | 9      | 8           | true   | 2025-06-18 04:02:41.876563+00 |
| 359             | 9      | 9           | true   | 2025-06-18 04:02:41.876563+00 |
| 360             | 9      | 12          | true   | 2025-06-18 04:02:41.876563+00 |
| 361             | 9      | 13          | true   | 2025-06-18 04:02:41.876563+00 |
| 362             | 9      | 1           | true   | 2025-06-18 04:02:41.876563+00 |
| 363             | 10     | 10          | true   | 2025-06-18 17:22:46.928588+00 |
| 364             | 10     | 11          | true   | 2025-06-18 17:22:46.928588+00 |
| 365             | 10     | 2           | true   | 2025-06-18 17:22:46.928588+00 |
| 366             | 10     | 3           | true   | 2025-06-18 17:22:46.928588+00 |
| 186             | 8      | 10          | true   | 2025-06-17 05:07:03.445026+00 |
| 187             | 8      | 8           | true   | 2025-06-17 05:07:03.445026+00 |
| 188             | 8      | 9           | true   | 2025-06-17 05:07:03.445026+00 |
| 367             | 10     | 6           | true   | 2025-06-18 17:22:46.928588+00 |
| 20              | 7      | 10          | true   | 2025-06-16 23:36:06.286955+00 |
| 21              | 7      | 11          | true   | 2025-06-16 23:36:06.286955+00 |
| 368             | 10     | 7           | true   | 2025-06-18 17:22:46.928588+00 |
| 369             | 10     | 8           | true   | 2025-06-18 17:22:46.928588+00 |
| 370             | 10     | 9           | true   | 2025-06-18 17:22:46.928588+00 |
| 371             | 10     | 12          | true   | 2025-06-18 17:22:46.928588+00 |
| 372             | 10     | 13          | true   | 2025-06-18 17:22:46.928588+00 |
| 373             | 10     | 1           | true   | 2025-06-18 17:22:46.928588+00 |
| 349             | 6      | 2           | true   | 2025-06-18 04:02:33.178597+00 |
| 350             | 6      | 3           | true   | 2025-06-18 04:02:33.178597+00 |
| 351             | 6      | 1           | true   | 2025-06-18 04:02:33.178597+00 |


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
