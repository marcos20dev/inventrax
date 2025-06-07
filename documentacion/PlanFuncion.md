# PLAN DE FUNCIONES PARA APP DE

# INVENTARIO – FLUTTER + SUPABASE + MVVM

## 1. Autenticación (usuarios)

Model:

- UsuarioModel con atributos: id, nombre, apellido, correo, createdAt

ViewModel: **AuthViewModel**

- signUp(nombre, apellido, correo, contraseña)
- signIn(correo, contraseña)
- signOut()
- getCurrentUser()
- isAuthenticated()

View:

- Pantalla de login
- Registro de usuario
- Pantalla principal tras login

## 2. Categorías de productos

Model:

- CategoriaModel con id, nombreCategoria, createdAt

ViewModel: **CategoriaViewModel**

- fetchCategorias()
- addCategoria(nombre)
- updateCategoria(id, nombre)
- deleteCategoria(id)

View:

- Lista de categorías
- Formulario para agregar/editar

## 3. Proveedores


Model:

- ProveedorModel con id, nombre, teléfono, correo, dirección, createdAt

ViewModel: **ProveedorViewModel**

- fetchProveedores()
- addProveedor(...)
- updateProveedor(id, ...)
- deleteProveedor(id)

View:

- Pantalla de lista de proveedores
- Formulario CRUD

## 4. Productos

Model:

- ProductoModel con campos como id, nombre, cantidad, precio,
  idCategoria, codigoBarras, etc.

ViewModel: **ProductoViewModel**

- fetchProductos()
- addProducto(...)
- updateProducto(id, ...)
- deleteProducto(id)
- buscarPorCodigoBarras(codigo)
- filtrarPorCategoria(idCategoria)

View:

- Lista con búsqueda
- Detalles del producto
- CRUD de producto
- Scan de código de barras (opcional)

## 5. Entradas de productos

Model:

- EntradaProductoModel con id, idProducto, idProveedor, cantidad, fecha,
  etc.


ViewModel: **EntradaProductoViewModel**

- fetchEntradas()
- registrarEntrada(idProducto, idProveedor, cantidad,
  precioCompra)
  o Aumenta stock del producto
  o Registra movimiento de inventario (tipo: entrada)

View:

- Lista de entradas
- Formulario para nueva entrada

## 6. Movimientos de Inventario

Model:

- MovimientoInventarioModel con tipo, cantidad, fecha, motivo, etc.

ViewModel: **InventarioViewModel**

- registrarMovimiento(idProducto, tipo, cantidad, motivo,
  destinatario?)
  o Valida stock si es salida
  o Resta o suma cantidad
- fetchMovimientos()
- filtrarMovimientosPorTipo(tipo)

View:

- Historial de movimientos
- Filtros por tipo o fecha

## 7. Clientes

Model:

- ClienteModel con id, tipo, nombre, apellido, razonSocial, documento, etc.

ViewModel: **ClienteViewModel**

- fetchClientes()
- addCliente(...)
- updateCliente(id, ...)
- deleteCliente(id)


View:

- Lista de clientes
- Formulario inteligente según tipo (persona o empresa)

## 8. Ventas y Detalle de ventas

Model:

- VentaModel y DetalleVentaModel

ViewModel: **VentaViewModel**

- crearVenta(clienteId, listaProductos, usuarioId)
  o Verifica stock
  o Resta cantidad
  o Registra movimiento tipo “salida”
- fetchVentas()
- getDetallesVenta(idVenta)

View:

- Registro de venta
- Carrito de productos
- Factura/boleta
- Lista de ventas

## 9. Generales / Globales

**AppViewModel** (global)

- initApp(): conecta Supabase, obtiene sesión actual, abre cajas si usas Hive
- setDarkMode()
- navegación entre módulos

## ¿Extras útiles?

- Escaneo de código de barras con flutter_barcode_scanner
- Gráficas de entradas/salidas con fl_chart
- Exportar datos a PDF o Excel con syncfusion_flutter_pdf
- Notificaciones locales si el stock está bajo
- Roles de usuarios (admin, vendedor)





## Cómo funciona normalmente el proceso de recuperación de contraseña:

1. Usuario hace clic en "Olvidé mi contraseña" y escribe su correo.
2. El sistema genera un token único y temporal (un código o enlace con un
   identificador).
3. El sistema envía ese token por correo al usuario.
4. El usuario recibe el correo, hace clic en el enlace o ingresa el código en la
   app/web.
5. El sistema valida el token y permite al usuario cambiar su contraseña.
6. El token expira tras un tiempo para seguridad.

## ¿Cómo enviar correos gratis para recuperación?

Hay servicios que permiten enviar correos transaccionales gratis con un plan básico:

- SendGrid: Tiene plan gratuito con 100 emails/día. Muy usado en apps.
- Mailgun: Plan gratuito con 5,000 emails/mes durante 3 meses.
- Amazon SES (Simple Email Service): Gratis hasta cierto límite si usas AWS.
- SMTP de Gmail: Puedes usarlo para enviar correos vía SMTP (límite diario de
  envío, requiere cuenta Gmail).
- Mailjet: Plan gratuito con 6,000 emails/mes.

## ¿Qué se necesita para implementar?

- Backend que genere y guarde el token temporal (en BD o cache).
- Servicio de correo configurado para enviar emails (ej. SendGrid).
- Endpoint para validar token y cambiar contraseña.
- Plantilla de correo con enlace o código.

## En resumen

```
Servicio Gratis Notas
SendGrid 100 emails/día API REST, fácil integración
Mailgun 5,000 emails/mes Necesita verificación
Gmail SMTP Limitado diario Fácil pero no profesional
Amazon SES Gratis con AWS Puede ser más complejo
Mailjet 6,000 emails/mes Plan gratuito con buenas opciones
```
