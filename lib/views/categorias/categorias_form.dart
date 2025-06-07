import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/categoria.dart';
import '../../viewmodels/categoria_viewmodel.dart';
import '../../widgets/widget_categoria/categoriaActionButton.dart';
import '../../widgets/widget_categoria/CategoriaNameField.dart';
import '../../widgets/widget_drawer/base_scaffold.dart';
import '../../widgets/widget_notification/Notification_Toast.dart';
import 'categorias_list.dart';

class CategoriaFormScreen extends StatefulWidget {
  final Map<String, dynamic>? categoria;

  const CategoriaFormScreen({Key? key, this.categoria}) : super(key: key);

  @override
  _CategoriaFormScreenState createState() => _CategoriaFormScreenState();
}

class _CategoriaFormScreenState extends State<CategoriaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  bool _isSubmitting = false;
  late Color _customPrimaryColor;

  final List<String> _categoriasSugeridas = [
    'Computadoras', 'Laptops', 'Componentes', 'Periféricos', 'Almacenamiento',
    'Redes', 'Tablets', 'Dispositivos Móviles', 'Accesorios', 'Impresión'
  ];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.categoria != null ? widget.categoria!['nombre'] ?? '' : '',
    );

    _customPrimaryColor = widget.categoria != null
        ? Colors.orange.shade400 // Edición
        : Colors.teal.shade400;   // Creación
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _navigateToListaCategorias() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoriaListScreen()),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final categoria = Categoria(
      idCategoria: widget.categoria?['id'],
      nombreCategoria: _nombreController.text.trim(),
    );

    try {
      final success = await context.read<CategoriaViewModel>().saveCategoria(categoria);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (success) {
        showNotificationToast(
          context,
          message: widget.categoria == null
              ? 'Categoría creada exitosamente'
              : 'Categoría actualizada',
          type: NotificationType.success,
        );

        if (widget.categoria == null) {
          _nombreController.clear();
          _formKey.currentState?.reset();
        } else {
          Navigator.of(context).pop(true);
        }
      } else {
        final errorMsg = context.read<CategoriaViewModel>().errorMessage;
        showNotificationToast(
          context,
          message: errorMsg ?? 'Error al guardar la categoría',
          type: NotificationType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      showNotificationToast(
        context,
        message: e.toString(),
        type: NotificationType.error,
      );
    }
  }

  Color _getPrimaryColor(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isDark) {
      return _customPrimaryColor == Colors.teal.shade400
          ? Colors.tealAccent.shade400
          : Colors.orangeAccent.shade400;
    }
    return _customPrimaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.categoria != null;
    final theme = Theme.of(context);
    final primaryColor = _getPrimaryColor(context);
    final surfaceColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade900.withOpacity(0.8)
        : Colors.white;
    final onSurfaceColor = theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    // Detectar el tamaño de la pantalla
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isLargeScreen = screenSize.width > 1200;

    return BaseScaffold(
      title: isEditing ? 'Editar Categoría' : 'Nueva Categoría',
      backgroundColor: surfaceColor.withOpacity(0.9),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24,
                vertical: isSmallScreen ? 16 : 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isSmallScreen) const SizedBox(height: 32),
                        CategoriaNameField(
                          controller: _nombreController,
                          isDark: theme.brightness == Brightness.dark,
                          primaryColor: primaryColor,
                          surfaceColor: surfaceColor,
                          onSurfaceColor: onSurfaceColor,
                          categoriasSugeridas: _categoriasSugeridas,
                          onCategoriaSelected: (categoria) {
                            _nombreController.text = categoria;
                            setState(() {});
                          },
                          labelText: 'NOMBRE DE LA CATEGORÍA',
                          suggestionsLabelText: 'SUGERENCIAS',
                        ),

                        const SizedBox(height: 16),
                        Align(
                          alignment: isSmallScreen
                              ? Alignment.center
                              : Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _navigateToListaCategorias,
                            icon: Icon(
                              Icons.list_alt,
                              color: primaryColor,
                              size: isSmallScreen ? 20 : 24,
                            ),
                            label: Text(
                              'Ver lista',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        CategoriaActionButton(
                          isEditing: isEditing,
                          isSubmitting: _isSubmitting,
                          primaryColor: primaryColor,
                          onSurfaceColor: onSurfaceColor,
                          onPressed: _submitForm,
                          isSmallScreen: isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}