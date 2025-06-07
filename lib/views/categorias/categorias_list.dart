import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventrax/views/categorias/categorias_form.dart';
import '../../widgets/widget_texfield/categoriaListItem.dart';
import '../../widgets/widget_drawer/base_scaffold.dart';
import '../../viewmodels/categoria_viewmodel.dart';
import '../../widgets/widget_notification/Notification_Toast.dart';  // Importa el ViewModel

class CategoriaListScreen extends StatefulWidget {
  @override
  _CategoriaListScreenState createState() => _CategoriaListScreenState();
}

class _CategoriaListScreenState extends State<CategoriaListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _displayedCategories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    final viewModel = context.read<CategoriaViewModel>();

    final categorias = await viewModel.getCategorias();

    setState(() {
      _displayedCategories = categorias.map((cat) {
        return {
          'id': cat.idCategoria,
          'nombre': cat.nombreCategoria,
          'color': Color(0xFF00C9A7), // fijo o puedes mapear desde cat si tienes color
          'icon': Icons.category,     // fijo (como pediste)
          'dependencia': false,       // o cat.dependencia si tienes
          'fecha_creacion': DateTime.now(), // o cat.fechaCreacion si tienes
        };
      }).toList();
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    final allCats = context.read<CategoriaViewModel>().getCategorias();

    // Para simplificar, filtra local _displayedCategories (ya cargadas)
    if (query.isEmpty) {
      _fetchCategories();  // Recarga todo
      return;
    }

    setState(() {
      _displayedCategories = _displayedCategories
          .where((cat) => cat['nombre'].toLowerCase().contains(query))
          .toList();
    });
  }

  void _editCategory(int id) async {
    final category = _displayedCategories.firstWhere((cat) => cat['id'] == id);
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CategoriaFormScreen(categoria: category),
      ),
    );

    if (result == true) {
      await _fetchCategories();
    }
  }


  void _deleteCategory(int id) async {
    final viewModel = context.read<CategoriaViewModel>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirmar eliminación',
          style: TextStyle(color: _getPrimaryColor(context)),
        ),
        content: Text('¿Estás seguro de que quieres eliminar esta categoría?'),
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
      final success = await viewModel.deleteCategoria(id);
      if (success) {
        showNotificationToast(
          context,
          message: 'Categoría eliminada',
          type: NotificationType.success,
        );
        await _fetchCategories();
      } else {
        showNotificationToast(
          context,
          message: 'Error al eliminar categoría',
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
      title: 'Categorías',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar categorías...',
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
              onRefresh: _fetchCategories,
              color: primaryColor,
              child: ListView.builder(
                controller: _scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: 8, bottom: 16),
                itemCount: _displayedCategories.length,
                itemBuilder: (context, index) {
                  final categoria = _displayedCategories[index];
                  return CategoriaListItem(
                    categoria: categoria,
                    primaryColor: primaryColor,
                    onEdit: (id) => _editCategory(id),
                    onDelete: (id) => _deleteCategory(id),
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
            MaterialPageRoute(builder: (context) => CategoriaFormScreen()),
          );
          if (result == true) {
            _fetchCategories();
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
