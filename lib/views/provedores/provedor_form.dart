import 'package:flutter/material.dart';
import 'package:inventrax/views/categorias/categorias_list.dart';
import 'package:inventrax/views/provedores/proveedores_sugeridos.dart';
import 'package:provider/provider.dart';
import '../../models/proveedor.dart';
import '../../viewmodels/proveedor_viewmodel.dart';
import '../../widgets/widget_categoria/categoriaActionButton.dart';
import '../../widgets/widget_drawer/base_scaffold.dart';
import '../../widgets/widget_notification/Notification_Toast.dart';
import '../../widgets/widget_texfield/textfield_widget.dart';

class ProveedorFormScreen extends StatefulWidget {
  final Map<String, dynamic>? proveedor;

  const ProveedorFormScreen({Key? key, this.proveedor}) : super(key: key);

  @override
  _ProveedorFormScreenState createState() => _ProveedorFormScreenState();
}

class _ProveedorFormScreenState extends State<ProveedorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, String>? _proveedorSeleccionado;

  late TextEditingController _nombreProveedorController;
  late TextEditingController _telefonoController;
  late TextEditingController _correoController;
  late TextEditingController _direccionController;

  bool _isSubmitting = false;
  late Color _customPrimaryColor;

  @override
  void initState() {
    super.initState();
    print("Proveedor recibido para ${widget.proveedor == null ? 'crear' : 'editar'}: ${widget.proveedor?.toString()}");

    _nombreProveedorController = TextEditingController(
      text: widget.proveedor != null ? widget.proveedor!['nombre'] ?? '' : '',
    );
    _telefonoController = TextEditingController(
      text: widget.proveedor != null ? widget.proveedor!['telefono'] ?? '' : '',
    );
    _correoController = TextEditingController(
      text: widget.proveedor != null ? widget.proveedor!['correo'] ?? '' : '',
    );
    _direccionController = TextEditingController(
      text: widget.proveedor != null ? widget.proveedor!['direccion'] ?? '' : '',
    );

    _customPrimaryColor = widget.proveedor != null
        ? Colors.orange.shade400
        : Colors.teal.shade400;
  }

  @override
  void dispose() {
    _nombreProveedorController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  void _cargarProveedor(Map<String, String> proveedor) {
    setState(() {
      _nombreProveedorController.text = proveedor['nombre'] ?? '';
      _telefonoController.text = proveedor['telefono'] ?? '';
      _correoController.text = proveedor['correo'] ?? '';
      _direccionController.text = proveedor['direccion'] ?? '';
      _proveedorSeleccionado = proveedor;
    });
  }

  Color _getPrimaryColor(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return isDark
        ? (_customPrimaryColor == Colors.teal.shade400
        ? Colors.tealAccent.shade400
        : Colors.orangeAccent.shade400)
        : _customPrimaryColor;
  }

  void _navigateToListaProveedores() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoriaListScreen()),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    print("Creando un nuevo proveedor...");

    final proveedor = Proveedor(
      idProveedor: widget.proveedor?['id_proveedor'] ?? widget.proveedor?['id'],
      nombreProveedor: _nombreProveedorController.text.trim(),
      telefono: _telefonoController.text.trim(),
      correo: _correoController.text.trim(),
      direccion: _direccionController.text.trim(),
    );

    try {
      final success = await context.read<ProveedorViewModel>().saveProveedor(proveedor);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (success) {
        showNotificationToast(
          context,
          message: widget.proveedor == null
              ? 'Proveedor registrado exitosamente'
              : 'Proveedor actualizado',
          type: NotificationType.success,
        );

        if (widget.proveedor == null) {
          // Recargar la página completamente
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProveedorFormScreen(),
            ),
          );
        } else {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      // Manejo de errores...
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.proveedor != null;
    final theme = Theme.of(context);
    final primaryColor = _getPrimaryColor(context);
    final surfaceColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade900.withOpacity(0.9)
        : Colors.white;
    final onSurfaceColor = theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return BaseScaffold(
      title: isEditing ? 'Editar Proveedor' : 'Registrar Proveedor',
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
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isSmallScreen) const SizedBox(height: 32),

                        // Sugerencias
                        Text(
                          'SUGERENCIAS',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: onSurfaceColor.withOpacity(0.6),
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: proveedoresSugeridos.map((proveedor) {
                            final isSelected = _proveedorSeleccionado == proveedor;
                            return InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => _cargarProveedor(proveedor),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? primaryColor : surfaceColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: onSurfaceColor.withOpacity(0.1),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  proveedor['nombre'] ?? '',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isSelected
                                        ? surfaceColor
                                        : onSurfaceColor.withOpacity(0.8),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 28),

                        TextFieldWidget(
                          controller: _nombreProveedorController,
                          isDark: theme.brightness == Brightness.dark,
                          primaryColor: primaryColor,
                          surfaceColor: surfaceColor,
                          onSurfaceColor: onSurfaceColor,
                          labelText: 'Nombre',
                          prefixIconData: Icons.business_rounded,
                        ),

                        const SizedBox(height: 12),

                        TextFieldWidget(
                          controller: _telefonoController,
                          isDark: theme.brightness == Brightness.dark,
                          primaryColor: primaryColor,
                          surfaceColor: surfaceColor,
                          onSurfaceColor: onSurfaceColor,
                          labelText: 'Teléfono',
                          keyboardType: TextInputType.phone,
                          prefixIconData: Icons.phone_rounded,
                        ),

                        const SizedBox(height: 12),

                        TextFieldWidget(
                          controller: _correoController,
                          isDark: theme.brightness == Brightness.dark,
                          primaryColor: primaryColor,
                          surfaceColor: surfaceColor,
                          onSurfaceColor: onSurfaceColor,
                          labelText: 'Correo',
                          keyboardType: TextInputType.emailAddress,
                          prefixIconData: Icons.email_rounded,
                        ),

                        const SizedBox(height: 12),

                        TextFieldWidget(
                          controller: _direccionController,
                          isDark: theme.brightness == Brightness.dark,
                          primaryColor: primaryColor,
                          surfaceColor: surfaceColor,
                          onSurfaceColor: onSurfaceColor,
                          labelText: 'Dirección',
                          prefixIconData: Icons.location_on_rounded,
                        ),

                        const Spacer(),

                        // Botón único para registrar/actualizar proveedor
                        CategoriaActionButton(
                          isEditing: isEditing,
                          isSubmitting: _isSubmitting,
                          primaryColor: primaryColor,
                          onSurfaceColor: onSurfaceColor,
                          onPressed: _submitForm,
                          isSmallScreen: isSmallScreen,
                          label: isEditing ? 'ACTUALIZAR PROVEEDOR' : 'REGISTRAR PROVEEDOR',
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
