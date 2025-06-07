import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cliente.dart';
import '../../widgets/widget_drawer/base_scaffold.dart';
import '../../viewmodels/cliente_viewmodel.dart';
import '../../widgets/widget_notification/Notification_Toast.dart';
import '../../widgets/widget_texfield/cliente_list_item.dart';
import 'clientes_form.dart';

class ClientesListScreen extends StatefulWidget {
  @override
  _ClientesListScreenState createState() => _ClientesListScreenState();
}

class _ClientesListScreenState extends State<ClientesListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Cliente> _allClientes = []; // Store original client list
  List<Cliente> _displayedClientes = []; // Store filtered client list
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchClientes());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchClientes() async {
    setState(() => _isLoading = true);
    final viewModel = context.read<ClienteViewModel>();

    try {
      await viewModel.loadClientes();
      setState(() {
        _allClientes = List.from(viewModel.clientes);
        _displayedClientes = List.from(_allClientes);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      showNotificationToast(
        context,
        message: 'Error al cargar clientes: ${e.toString()}',
        type: NotificationType.error,
      );
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      setState(() => _displayedClientes = List.from(_allClientes));
      return;
    }

    setState(() {
      _displayedClientes = _allClientes.where((cliente) {
        return cliente.nombre!.toLowerCase().contains(query) ||
            (cliente.telefono?.toLowerCase().contains(query) ?? false) ||
            (cliente.correo?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  void _editCliente(int id) async {
    try {
      final cliente = _allClientes.firstWhere((c) => c.idCliente == id);

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => ClientesFormScreen(cliente: cliente),
        ),
      );

      if (result == true) await _fetchClientes();
    } catch (e) {
      showNotificationToast(
        context,
        message: 'Cliente no encontrado',
        type: NotificationType.error,
      );
    }
  }

  void _deleteCliente(int id) async {
    final viewModel = context.read<ClienteViewModel>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirmar eliminación',
            style: TextStyle(color: _getPrimaryColor(context))),
        content: Text('¿Estás seguro de que quieres eliminar este cliente?'),
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

    if (confirmed != true) return;

    try {
      final success = await viewModel.deleteCliente(id);

      if (success) {
        showNotificationToast(
          context,
          message: 'Cliente eliminado',
          type: NotificationType.success,
        );
        await _fetchClientes();
      } else {
        showNotificationToast(
          context,
          message: 'Error al eliminar cliente',
          type: NotificationType.error,
        );
      }
    } catch (e) {
      showNotificationToast(
        context,
        message: 'Error: ${e.toString()}',
        type: NotificationType.error,
      );
    }
  }

  Color _getPrimaryColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.tealAccent.shade400
        : Colors.teal.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getPrimaryColor(context);

    return BaseScaffold(
      title: 'Clientes',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar clientes...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[100],
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
              onRefresh: _fetchClientes,
              color: primaryColor,
              child: _displayedClientes.isEmpty
                  ? Center(
                child: Text(
                  _searchController.text.isEmpty
                      ? 'No hay clientes registrados'
                      : 'No se encontraron resultados',
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: 8, bottom: 16),
                itemCount: _displayedClientes.length,
                itemBuilder: (context, index) {
                  final cliente = _displayedClientes[index];
                  return ClienteListItem(
                    cliente: {
                      'id': cliente.idCliente,
                      'nombre': cliente.nombre,
                      'tipo_cliente': cliente.tipoCliente,
                      'telefono': cliente.telefono,
                      'correo': cliente.correo,
                      'direccion': cliente.direccion,
                      'fecha_creacion': cliente.createdAt,
                    },
                    primaryColor: primaryColor,
                    onEdit: _editCliente,
                    onDelete: _deleteCliente,
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
            MaterialPageRoute(builder: (context) => ClientesFormScreen()),
          );
          if (result == true) _fetchClientes();
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}