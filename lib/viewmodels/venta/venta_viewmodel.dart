import 'package:flutter/material.dart';

import '../../models/cliente.dart';
import '../../models/producto.dart';
import '../../repositories/cliente_repository.dart';
import '../../repositories/producto_repository.dart';
import '../../widgets/widget_notification/Notification_Toast.dart';

class VentasViewModel extends ChangeNotifier {
  bool isLoading = false;

  // Campos para cliente
  String tipoCliente = 'Persona Natural';
  final TextEditingController rucController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController nombreClienteController = TextEditingController();
  final TextEditingController correoController = TextEditingController();

  // Controladores para producto y venta
  final TextEditingController clienteController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();

  final TextEditingController productoController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController(text: '1');
  final TextEditingController precioController = TextEditingController();

  // Controladores para código de barras y datos producto
  final TextEditingController codigoBarrasController = TextEditingController();
  final TextEditingController nombreProductoController = TextEditingController();
  final TextEditingController descripcionProductoController = TextEditingController();

  final FocusNode productoFocusNode = FocusNode();
  final FocusNode cantidadFocusNode = FocusNode();
  final FocusNode precioFocusNode = FocusNode();

  final Color primaryColor = Colors.teal.shade700;
  final double fieldSpacing = 16;

  List<Map<String, dynamic>> productos = [];

  // Repositorios inyectados
  final ClientesRepository _clientesRepository;
  final ProductoRepository _productoRepository;

  // Cliente seleccionado
  Cliente? clienteSeleccionado;

  // Producto seleccionado completo para obtener idProducto
  Producto? _productoSeleccionado;

  // Callback para notificaciones
  void Function(String message, NotificationType type)? onShowToast;

  VentasViewModel(this._clientesRepository, this._productoRepository) {
    _setInitialDate();
    _setupFocusNodes();
    final FocusNode cantidadFocusNode = FocusNode();

    codigoBarrasController.addListener(_onCodigoBarrasChanged);
    rucController.addListener(_onInputChanged);
    dniController.addListener(_onInputChanged);
  }

  final TextEditingController precioTotalController = TextEditingController(text: '0.00');

  void actualizarPrecioTotal() {
    final cantidad = int.tryParse(cantidadController.text) ?? 1;
    final precioUnitario = double.tryParse(precioController.text) ?? 0.0;
    final total = cantidad * precioUnitario;
    precioTotalController.text = total.toStringAsFixed(2);
    notifyListeners();
  }

  void _clearProductoFields() {
    productoController.clear();
    cantidadController.text = '1';
    precioController.clear();
    precioTotalController.text = '0.00';
    codigoBarrasController.clear();
    nombreProductoController.clear();
    descripcionProductoController.clear();

    _productoSeleccionado = null; // limpiar producto seleccionado
  }

  void _onCodigoBarrasChanged() {
    final codigo = codigoBarrasController.text.trim();
    if (codigo.isNotEmpty) {
      buscarProductoPorCodigo(codigo);
    } else {
      _productoSeleccionado = null; // <- IMPORTANTE: limpiar aquí
      nombreProductoController.clear();
      descripcionProductoController.clear();
      precioController.clear();
      cantidadController.text = '1';
      notifyListeners();
    }
  }


  void _onInputChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    clienteController.dispose();
    fechaController.dispose();
    productoController.dispose();
    cantidadController.dispose();
    precioController.dispose();
    codigoBarrasController.dispose();
    nombreProductoController.dispose();
    descripcionProductoController.dispose();
    rucController.dispose();
    dniController.dispose();
    nombreClienteController.dispose();
    correoController.dispose();

    productoFocusNode.dispose();
    cantidadFocusNode.dispose();
    precioFocusNode.dispose();

    super.dispose();
  }

  void setTipoCliente(String value) {
    tipoCliente = value;
    rucController.clear();
    dniController.clear();
    nombreClienteController.clear();
    correoController.clear();
    clienteSeleccionado = null;
    notifyListeners();
  }

  void _setInitialDate() {
    fechaController.text = _formatDate(DateTime.now());
  }

  void _setupFocusNodes() {
    precioFocusNode.addListener(() {
      if (!precioFocusNode.hasFocus &&
          productoController.text.isNotEmpty &&
          cantidadController.text.isNotEmpty &&
          precioController.text.isNotEmpty) {
        agregarProducto();
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> seleccionarFecha(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      fechaController.text = _formatDate(date);
      notifyListeners();
    }
  }

  bool validarCamposProducto() {
    final cantidadValida = int.tryParse(cantidadController.text) != null && int.parse(cantidadController.text) > 0;

    if (!cantidadValida) {
      print('Cantidad inválida: ${cantidadController.text}');
    }

    return cantidadValida;
  }

  void agregarProducto() {
    print('agregarProducto() llamado');
    if (!validarCamposProducto()) {
      print('Validación fallida');
      onShowToast?.call('Por favor ingresa una cantidad válida', NotificationType.warning);
      return;
    }

    final cantidadNueva = int.tryParse(cantidadController.text) ?? 1;
    final precioUnitario = double.tryParse(precioController.text) ?? 0.0;
    final nombreProducto = nombreProductoController.text.trim();

    if (_productoSeleccionado == null) {
      onShowToast?.call('Producto inválido, por favor busca nuevamente', NotificationType.error);
      return;
    }

    final idProducto = _productoSeleccionado!.idProducto;

    print('Producto a agregar: $nombreProducto, cantidad: $cantidadNueva, precio: $precioUnitario, idProducto: $idProducto');

    final indexExistente = productos.indexWhere((p) => p['id_producto'] == idProducto);

    if (indexExistente >= 0) {
      productos[indexExistente]['cantidad'] += cantidadNueva;
    } else {
      productos.add({
        'id_producto': idProducto,
        'nombre': nombreProducto,
        'cantidad': cantidadNueva,
        'precio': precioUnitario,
      });
    }

    _clearProductoFields();
    notifyListeners();
  }

  bool get isBuscarClienteEnabled {
    if (tipoCliente == 'Empresa') {
      return rucController.text.length == 11;
    } else {
      return dniController.text.length == 8;
    }
  }
  bool isLoadingCliente = false;
  bool isLoadingProducto = false;

  Future<void> buscarClientePorDni(String dni) async {
    isLoadingCliente = true;

    notifyListeners();

    try {
      final cliente = await _clientesRepository.buscarClientePorDni(dni);
      if (cliente != null) {
        nombreClienteController.text =
            '${cliente.nombre ?? ''} ${cliente.apellido ?? ''}'.trim();
        dniController.text = cliente.documentoIdentidad;
        correoController.text = cliente.correo;
        clienteSeleccionado = cliente;

        onShowToast?.call("Cliente encontrado", NotificationType.success);
      } else {
        nombreClienteController.clear();
        dniController.clear();
        correoController.clear();
        clienteSeleccionado = null;

        onShowToast?.call("Cliente no encontrado", NotificationType.error);
      }
    } catch (e) {
      print('Error buscando cliente: $e');
      onShowToast?.call("Error al buscar cliente", NotificationType.error);
    } finally {
      isLoadingCliente = false;
      notifyListeners();
    }
  }

  void setClienteSeleccionado(Cliente cliente) {
    clienteSeleccionado = cliente;
    nombreClienteController.text =
        '${cliente.nombre ?? ''} ${cliente.apellido ?? ''}'.trim();
    dniController.text = cliente.documentoIdentidad;
    correoController.text = cliente.correo;
    notifyListeners();
  }

  void eliminarProducto(int index) {
    productos.removeAt(index);
    notifyListeners();
  }

  double get totalVenta =>
      productos.fold(0, (sum, item) => sum + (item['cantidad'] * item['precio']));

  void resetForm() {
    rucController.clear();
    dniController.clear();
    nombreClienteController.clear();
    correoController.clear();
    codigoBarrasController.clear();
    nombreProductoController.clear();
    descripcionProductoController.clear();
    cantidadController.text = '1';
    precioController.clear();
    precioTotalController.text = '0.00';
    productos.clear();
    clienteSeleccionado = null;
    notifyListeners();
  }


  Future<void> buscarProductoPorCodigo(String codigo) async {
    isLoadingProducto = true;
    notifyListeners();

    try {
      final producto = await _productoRepository.getProductoPorCodigoBarras(codigo);
      if (producto != null) {
        _productoSeleccionado = producto;  // guarda producto completo

        nombreProductoController.text = producto.nombreProducto;
        descripcionProductoController.text = producto.descripcion ?? '';
        precioController.text = producto.precioVenta.toStringAsFixed(2);
        cantidadController.text = '1';

        productoController.text = producto.nombreProducto;

        actualizarPrecioTotal();
      } else {
        _productoSeleccionado = null;

        nombreProductoController.clear();
        descripcionProductoController.clear();
        precioController.clear();
        cantidadController.text = '1';
        precioTotalController.text = '0.00';
        productoController.clear();
        onShowToast?.call('Producto no encontrado', NotificationType.error);
      }
    } catch (e) {
      _productoSeleccionado = null;

      nombreProductoController.clear();
      descripcionProductoController.clear();
      precioController.clear();
      cantidadController.text = '1';
      precioTotalController.text = '0.00';
      productoController.clear();
      onShowToast?.call('Error al buscar producto', NotificationType.error);
    } finally {
      isLoadingProducto = false;
      notifyListeners();
    }
  }
}
