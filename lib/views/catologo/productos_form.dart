import 'package:flutter/material.dart';
import 'package:inventrax/views/catologo/secciones/DetalleEntradaSection.dart';
import 'package:inventrax/views/catologo/secciones/MovimientoInventarioSection.dart';
import 'package:inventrax/views/catologo/secciones/ProductoInfoSection.dart';
import 'package:provider/provider.dart';

import '../../repositories/producto_repository.dart';
import '../../services/ChangeNotifier.dart';
import '../../viewmodels/categoria_viewmodel.dart';
import '../../viewmodels/producto_viewmodel.dart';
import '../../viewmodels/proveedor_viewmodel.dart';
import '../../widgets/widget_drawer/base_scaffold.dart';
import '../../widgets/widget_producto/DropdownField.dart';
import '../../widgets/widget_producto/ProductoTextField.dart';
import '../../widgets/widget_producto/ScannerWidget.dart';
import '../../widgets/widget_notification/Notification_Toast.dart';

class ProductosFormScreen extends StatefulWidget {
  const ProductosFormScreen({Key? key}) : super(key: key);

  @override
  State<ProductosFormScreen> createState() => _ProductosFormScreenState();
}

class _ProductosFormScreenState extends State<ProductosFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Controladores
  late final TextEditingController _codigoBarrasController;
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _cantidadController;
  late final TextEditingController _precioCompraController;
  late final TextEditingController _precioVentaController;
  late final TextEditingController _categoriaController;
  late final TextEditingController _proveedorController; // Nuevo controlador proveedor

  // Estado del formulario
  String _selectedUnidadMedida = 'unidad';
  bool _busquedaRealizada = false;

  @override
  void initState() {
    super.initState();
    // Inicializa los controladores con valores vacíos
    _codigoBarrasController = TextEditingController();
    _nombreController = TextEditingController();
    _descripcionController = TextEditingController();
    _cantidadController = TextEditingController();
    _precioCompraController = TextEditingController();
    _precioVentaController = TextEditingController();
    _categoriaController = TextEditingController();
    _proveedorController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategorias();
      _loadProveedores();
    });
  }

  @override
  void dispose() {
    // Asegúrate de limpiar los controladores cuando ya no se necesiten
    _codigoBarrasController.dispose();
    _nombreController.dispose();
    _descripcionController.dispose();
    _cantidadController.dispose();
    _precioCompraController.dispose();
    _precioVentaController.dispose();
    _categoriaController.dispose();
    _proveedorController.dispose();
    super.dispose();
  }

  void _submitForm(ProductoViewModel viewModel) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_categoriaController.text.isEmpty) {
      showNotificationToast(context, message: 'Seleccione una categoría', type: NotificationType.error);
      return;
    }
    if (_proveedorController.text.isEmpty) {
      showNotificationToast(context, message: 'Seleccione un proveedor', type: NotificationType.error);
      return;
    }
    final userUid = context.read<UserSession>().uid; // O el provider que uses

    print('UID usuario para movimiento: $userUid'); // Para verificar

    final productData = <String, dynamic>{
      'codigo_barras': _codigoBarrasController.text.trim(),
      'nombre_producto': _nombreController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'cantidad_disponible': int.tryParse(_cantidadController.text.trim()) ?? 0,
      'precio_venta': double.tryParse(_precioVentaController.text.trim()) ?? 0.0,
      'unidad_medida': _selectedUnidadMedida,
      'id_categoria': int.tryParse(_categoriaController.text.trim()) ?? 0,
    };

    final entradaData = <String, dynamic>{
      'id_proveedor': int.tryParse(_proveedorController.text.trim()) ?? 0,
      'cantidad': int.tryParse(_cantidadController.text.trim()) ?? 0,
      'fecha_entrada': DateTime.now().toIso8601String(),
      'precio_compra': (double.tryParse(_precioCompraController.text.trim()) ?? 0.0).toInt(),
    };

    final movimientoData = <String, dynamic>{
      'id_usuario': userUid,
      'tipo_movimiento': 'entrada',
      'cantidad': int.tryParse(_cantidadController.text.trim()) ?? 0,
      'fecha_movimiento': DateTime.now().toIso8601String(),
      'motivo': 'Stock inicial',
      'destinatario': 'Almacén Central',
    };

    viewModel.saveProduct(
      producto: productData,
      entrada: entradaData,
      movimiento: movimientoData,
    ).then((exito) {
      if (exito) {
        _mostrarNotificacion(true);
        _resetForm();
        viewModel.reset();  // <-- Limpia valores en ViewModel también
      } else {
        _mostrarNotificacion(false);
      }
    });
  }

  void _loadCategorias() async {
    final categoriaVM = context.read<CategoriaViewModel>();
    await categoriaVM.getCategorias();
  }

  void _loadProveedores() async {
    final proveedorVM = context.read<ProveedorViewModel>();
    await proveedorVM.loadProveedores();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _codigoBarrasController.clear();
    _nombreController.clear();
    _descripcionController.clear();
    _cantidadController.clear();
    _precioCompraController.clear();
    _precioVentaController.clear();
    _categoriaController.clear();
    _proveedorController.clear();
    setState(() => _selectedUnidadMedida = 'unidad');
  }

  void _mostrarNotificacion(bool exito) {
    final mensaje = exito ? 'Producto guardado correctamente' : 'Error al guardar el producto';
    final tipo = exito ? NotificationType.success : NotificationType.error;
    showNotificationToast(context, message: mensaje, type: tipo);
  }

  // Elimina el método _syncControllerWithViewModel

  Future<void> _handleBarcodeScan(ProductoViewModel viewModel) async {
    try {
      final scannedCode = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => ScannerWidget(viewModel: viewModel)),
      );

      if (scannedCode != null && scannedCode.isNotEmpty) {
        // Limpiar los campos ANTES de asignar el nuevo código
        setState(() {
          _nombreController.clear();
          _descripcionController.clear();
          _codigoBarrasController.text = scannedCode;
          _busquedaRealizada = false;
        });

        // Buscar información del nuevo código
        await viewModel.fetchProductInfo(scannedCode);

        // Actualizar UI si se encontró información
        if (viewModel.productoEncontrado) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _nombreController.text = viewModel.nombre;
                _descripcionController.text = viewModel.descripcion;
                _busquedaRealizada = true;
              });
            }
          });
        }
      }
    } catch (e) {
      print('Error en escaneo: $e');
      if (mounted) {
        showNotificationToast(context,
            message: 'Error al escanear código',
            type: NotificationType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.teal.shade400;
    final Color surfaceColor = Colors.white;
    final Color onSurfaceColor = Colors.black;

    final proveedorVM = context.watch<ProveedorViewModel>();
    final categoriaVM = context.watch<CategoriaViewModel>();

    final categoriaItems = categoriaVM.isLoading
        ? <DropdownMenuItem<String>>[]
        : categoriaVM.categorias
        .map((cat) => DropdownMenuItem(
      value: cat.idCategoria.toString(),
      child: Text(cat.nombreCategoria),
    ))
        .toList();

    final proveedorItems = proveedorVM.isLoading
        ? <DropdownMenuItem<String>>[]
        : proveedorVM.proveedores
        .map((prov) => DropdownMenuItem(
      value: prov.idProveedor.toString(),
      child: Text(prov.nombreProveedor),
    ))
        .toList();

    return ChangeNotifierProvider(
      create: (_) => ProductoViewModel(repository: ProductoRepository()),
      child: Consumer<ProductoViewModel>(builder: (context, viewModel, _) {
        return BaseScaffold(
          title: 'Nuevo Producto',
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProductoInfoSection(
                    categoriaController: _categoriaController,
                    categoriaItems: categoriaItems,
                    onCategoriaChanged: (val) {
                      if (val != null) setState(() => _categoriaController.text = val);
                    },
                    codigoBarrasController: _codigoBarrasController,
                    onBarcodeScan: () => _handleBarcodeScan(viewModel),
                    nombreController: _nombreController,
                    descripcionController: _descripcionController,
                    cantidadController: _cantidadController,
                    precioVentaController: _precioVentaController,
                    unidadMedida: _selectedUnidadMedida,
                    primaryColor: primaryColor,
                    surfaceColor: surfaceColor,
                    onSurfaceColor: onSurfaceColor,
                    fieldSpacing: 20,
                    isSmallScreen: MediaQuery.of(context).size.width < 600,
                    validateCategoria: (val) => val == null || val.isEmpty ? 'Seleccione una categoría' : null,
                    validateCantidad: (val) => val == null || val.isEmpty ? 'Ingrese cantidad' : null,
                    validatePrecio: (val) {
                      if (val == null || val.isEmpty) return 'Ingrese precio';
                      if (double.tryParse(val) == null) return 'Ingrese un número válido';
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  DetalleEntradaSection(
                    precioCompraController: _precioCompraController,
                    proveedorController: _proveedorController,
                    proveedorItems: proveedorItems,
                    onProveedorChanged: (val) {
                      setState(() => _proveedorController.text = val ?? '');
                    },
                    primaryColor: primaryColor,
                    surfaceColor: surfaceColor,
                    onSurfaceColor: onSurfaceColor,
                    fieldSpacing: 20,
                  ),
                  SizedBox(height: 30),
                  MovimientoInventarioSection(
                    fieldSpacing: 20,
                    primaryColor: primaryColor,
                    surfaceColor: surfaceColor,
                    onSurfaceColor: onSurfaceColor,
                    onMotivoChanged: (val) {
                      print("Motivo seleccionado: $val");
                    },
                  ),
                  SizedBox(height: 30),
                  _buildSaveButton(viewModel, primaryColor),
                  if (viewModel.isLoading) const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSaveButton(ProductoViewModel viewModel, Color primaryColor) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: viewModel.isLoading ? null : () => _submitForm(viewModel),
      child: viewModel.isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
        'Guardar Producto',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
