import 'package:flutter/material.dart';
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
          .where((prod) => prod['nombre_producto'].toLowerCase().contains(query))
          .toList();
    });
  }

  void _deleteProducto(int id) async {
    final viewModel = context.read<ProductoViewModel>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirmar eliminación', style: TextStyle(color: _getPrimaryColor(context))),
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