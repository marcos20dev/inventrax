import 'package:flutter/material.dart';
import 'package:inventrax/views/provedores/provedor_form.dart';
import 'package:provider/provider.dart';

import '../../widgets/widget_drawer/base_scaffold.dart';
import '../../viewmodels/proveedor_viewmodel.dart';
import '../../widgets/widget_notification/Notification_Toast.dart';
import '../../widgets/widget_texfield/ProveedorListItem.dart';

class ProveedorListScreen extends StatefulWidget {
  @override
  _ProveedorListScreenState createState() => _ProveedorListScreenState();
}

class _ProveedorListScreenState extends State<ProveedorListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _displayedProveedores = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProveedores();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProveedores() async {
    setState(() => _isLoading = true);
    final viewModel = context.read<ProveedorViewModel>();

    final proveedores = await viewModel.getAllProveedores();

    setState(() {
      _displayedProveedores = proveedores.map((prov) {
        return {
          'id': prov.idProveedor,
          'nombre': prov.nombreProveedor,
          'telefono': prov.telefono,
          'correo': prov.correo,
          'direccion': prov.direccion,
          'icon': Icons.business_rounded,  // ejemplo fijo
          'fecha_creacion': DateTime.now(), // si tienes campo fecha lo usas
        };
      }).toList();
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      _fetchProveedores();
      return;
    }

    setState(() {
      _displayedProveedores = _displayedProveedores
          .where((prov) => prov['nombre'].toLowerCase().contains(query))
          .toList();
    });
  }

  void _editProveedor(int id) async {
    final proveedor = _displayedProveedores.firstWhere((p) => p['id'] == id);
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProveedorFormScreen(proveedor: proveedor),
      ),
    );
    if (result == true) {
      await _fetchProveedores();
    }
  }




  void _deleteProveedor(int id) async {
    final viewModel = context.read<ProveedorViewModel>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirmar eliminación', style: TextStyle(color: _getPrimaryColor(context))),
        content: Text('¿Estás seguro de que quieres eliminar este proveedor?'),
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
      final success = await viewModel.deleteProveedor(id);
      if (success) {
        showNotificationToast(
          context,
          message: 'Proveedor eliminado',
          type: NotificationType.success,
        );
        await _fetchProveedores();
      } else {
        showNotificationToast(
          context,
          message: 'Error al eliminar proveedor',
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
      title: 'Proveedores',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar proveedores...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
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
              onRefresh: _fetchProveedores,
              color: primaryColor,
              child: ListView.builder(
                controller: _scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: 8, bottom: 16),
                itemCount: _displayedProveedores.length,
                itemBuilder: (context, index) {
                  final proveedor = _displayedProveedores[index];
                  return ProveedorListItem(
                    proveedor: proveedor,
                    primaryColor: primaryColor,
                    onEdit: (id) => _editProveedor(id),
                    onDelete: (id) => _deleteProveedor(id),
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
            MaterialPageRoute(builder: (context) => ProveedorFormScreen()),
          );
          if (result == true) {
            _fetchProveedores();
          }
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
