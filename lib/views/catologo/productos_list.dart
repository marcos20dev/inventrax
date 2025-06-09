import 'package:flutter/material.dart';
import 'package:inventrax/models/producto.dart';
import 'package:inventrax/views/catologo/productos_form.dart';
import 'package:provider/provider.dart';
import '../../repositories/producto_repository.dart';
import '../../viewmodels/producto_viewmodel.dart';
import '../../widgets/widget_drawer/base_scaffold.dart';
import '../../widgets/widget_notification/Notification_Toast.dart';
import '../../widgets/widget_producto/ProductoListItem.dart';

class ProductoListScreen extends StatefulWidget {
  @override
  _ProductoListScreenState createState() => _ProductoListScreenState();
}

class _ProductoListScreenState extends State<ProductoListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _displayedProductos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProductos();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductos() async {
    setState(() => _isLoading = true);
    final viewModel = context.read<ProductoViewModel>();

    final productos = await viewModel.getAllProducts();

    setState(() {
      _displayedProductos = productos.map((prod) {
        return {
          'id_producto': prod.idProducto,
          'codigo_barras': prod.codigoBarras,
          'nombre_producto': prod.nombreProducto,
          'descripcion': prod.descripcion,
          'cantidad_disponible': prod.cantidadDisponible,
          'precio_venta': prod.precioVenta,
          'unidad_medida': prod.unidadMedida,
        };
      }).toList();
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      _fetchProductos();
      return;
    }

    setState(() {
      _displayedProductos = _displayedProductos
          .where((prod) =>
          prod['nombre_producto'].toLowerCase().contains(query))
          .toList();
    });
  }

  void _deleteProducto(int id) async {
    final viewModel = context.read<ProductoViewModel>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirmar eliminación',
            style: TextStyle(color: _getPrimaryColor(context))),
        content: const Text('¿Estás seguro de que quieres eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCELAR', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await viewModel.deleteProduct(id);
      if (success) {
        showNotificationToast(
          context,
          message: 'Producto eliminado',
          type: NotificationType.success,
        );
        await _fetchProductos();
      } else {
        showNotificationToast(
          context,
          message: 'Error al eliminar producto',
          type: NotificationType.error,
        );
      }
    }
  }

  Color _getPrimaryColor(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return isDark ? Colors.tealAccent.shade400 : Colors.teal.shade400;
  }

  void _showProductDetailsModal(Map<String, dynamic> producto) {
    final TextEditingController _nombreController = TextEditingController(text: producto['nombre_producto']);
    final TextEditingController _descripcionController = TextEditingController(text: producto['descripcion']);
    final TextEditingController _cantidadController = TextEditingController(text: producto['cantidad_disponible'].toString());
    final TextEditingController _precioVentaController = TextEditingController(text: producto['precio_venta'].toString());
    final TextEditingController _proveedorController = TextEditingController(text: producto['proveedor']?.toString() ?? '');
    final TextEditingController _codigoBarrasController = TextEditingController(text: producto['codigo_barras']?.toString() ?? '');
    final TextEditingController _precioCompraController = TextEditingController(text: producto['precio_compra']?.toString() ?? '');

    String? _selectedCategoria = producto['categoria']; // Asignar la categoría seleccionada

    // Lista de categorías, reemplaza esto con las categorías reales disponibles
    List<String> categorias = ['Electrónica', 'Ropa', 'Alimentos', 'Juguetes'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Editar Producto',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getPrimaryColor(context),
                  ),
                ),
                const SizedBox(height: 20),

                // Categoría
                const SizedBox(height: 20),
                Text(
                  'Categoría',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getPrimaryColor(context),
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedCategoria,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategoria = newValue;
                    });
                  },
                  items: categorias.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),

                // Código de barras
                _buildEditableRow('Código de Barras', _codigoBarrasController),

                // Nombre
                _buildEditableRow('Nombre', _nombreController),

                // Descripción
                _buildEditableRow('Descripción', _descripcionController),

                // Cantidad
                _buildEditableRow('Cantidad', _cantidadController),

                // Precio de venta
                _buildEditableRow('Precio de venta', _precioVentaController),

                // Selección de proveedor
                const SizedBox(height: 20),
                Text(
                  'Proveedor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getPrimaryColor(context),
                  ),
                ),
                _buildEditableRow('Proveedor', _proveedorController),

                // Precio de compra
                _buildEditableRow('Precio de compra', _precioCompraController),

                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final updatedProducto = {
                            'id_producto': producto['id_producto'],
                            'nombre_producto': _nombreController.text,
                            'descripcion': _descripcionController.text,
                            'cantidad_disponible': int.tryParse(_cantidadController.text) ?? 0,
                            'precio_venta': double.tryParse(_precioVentaController.text) ?? 0.0,
                            'proveedor': _proveedorController.text,
                            'categoria': _selectedCategoria,
                            'codigo_barras': _codigoBarrasController.text,
                            'precio_compra': double.tryParse(_precioCompraController.text) ?? 0.0,
                          };

                          context.read<ProductoViewModel>().updateProduct(updatedProducto as Producto).then((success) {
                            if (success) {
                              showNotificationToast(context, message: 'Producto actualizado', type: NotificationType.success);
                              Navigator.pop(context);
                              _fetchProductos();
                            } else {
                              showNotificationToast(context, message: 'Error al actualizar producto', type: NotificationType.error);
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getPrimaryColor(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'Actualizar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  Widget _buildEditableRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                )),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getPrimaryColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseScaffold(
      title: 'Productos',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintStyle: TextStyle(color: Colors.grey),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : RefreshIndicator(
              onRefresh: _fetchProductos,
              color: primaryColor,
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                itemCount: _displayedProductos.length,
                itemBuilder: (context, index) {
                  final producto = _displayedProductos[index];
                  return ProductoListItem(
                    producto: producto,
                    primaryColor: primaryColor,
                    onDelete: (id) => _deleteProducto(id),
                    onEdit: (id) => _showProductDetailsModal(producto),
                    trailing: IconButton(  // Aquí pasamos el IconButton para trailing
                      icon: Icon(Icons.more_vert, color: Colors.grey),
                      onPressed: () {
                        // Este es el modal de opciones
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (context) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.edit, color: primaryColor),
                                title: const Text('Editar'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _showProductDetailsModal(producto);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete, color: Colors.red),
                                title: const Text('Eliminar'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _deleteProducto(producto['id_producto']);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const ProductosFormScreen()),
          );
          if (result == true) {
            _fetchProductos();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
