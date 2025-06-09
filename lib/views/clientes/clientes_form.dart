import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cliente.dart';
import '../../viewmodels/cliente_viewmodel.dart';
import '../../widgets/widget_drawer/base_scaffold.dart';
import '../../widgets/widget_notification/Notification_Toast.dart';
import '../../widgets/widget_producto/DropdownField.dart';
import '../../widgets/widget_texfield/textfield_widget.dart';

class ClientesFormScreen extends StatefulWidget {
  final Cliente? cliente;
  const ClientesFormScreen({Key? key, this.cliente}) : super(key: key);

  @override
  State<ClientesFormScreen> createState() => _ClientesFormScreenState();
}

class _ClientesFormScreenState extends State<ClientesFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Color _primaryColor = Colors.teal.shade400;

  late String? tipoCliente;
  late TextEditingController nombreController;
  late TextEditingController apellidoController;
  late TextEditingController razonSocialController;
  late TextEditingController documentoIdentidadController;
  late TextEditingController telefonoController;
  late TextEditingController correoController;
  late TextEditingController direccionController;

  @override
  void initState() {
    super.initState();
    _primaryColor = widget.cliente == null
        ? Colors.teal.shade400
        : Colors.blue.shade700;
    _inicializarControladores();
  }

  void _inicializarControladores() {
    final c = widget.cliente;

    // Establecer el tipo de cliente predeterminado si no existe
    tipoCliente = c?.tipoCliente ?? 'persona';  // 'persona' es el valor por defecto

    nombreController = TextEditingController(text: c?.nombre ?? '');
    apellidoController = TextEditingController(text: c?.apellido ?? '');
    razonSocialController = TextEditingController(text: c?.razonSocial ?? '');
    documentoIdentidadController = TextEditingController(text: c?.documentoIdentidad ?? '');
    telefonoController = TextEditingController(text: c?.telefono ?? '');
    correoController = TextEditingController(text: c?.correo ?? '');
    direccionController = TextEditingController(text: c?.direccion ?? '');
  }



  void _limpiarFormulario() {
    setState(() {
      tipoCliente = null;
      nombreController.clear();
      apellidoController.clear();
      razonSocialController.clear();
      documentoIdentidadController.clear();
      telefonoController.clear();
      correoController.clear();
      direccionController.clear();
      _formKey.currentState?.reset();
    });
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    razonSocialController.dispose();
    documentoIdentidadController.dispose();
    telefonoController.dispose();
    correoController.dispose();
    direccionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newCliente = Cliente(
        idCliente: widget.cliente?.idCliente,
        tipoCliente: tipoCliente ?? 'persona',
        nombre: nombreController.text.trim(),
        apellido: tipoCliente == 'persona' ? apellidoController.text.trim() : null,
        razonSocial: tipoCliente == 'empresa' ? razonSocialController.text.trim() : null,
        documentoIdentidad: documentoIdentidadController.text.trim(),
        telefono: telefonoController.text.trim(),
        correo: correoController.text.trim(),
        direccion: direccionController.text.trim(),
      );

      final vm = context.read<ClienteViewModel>();
      bool success;
      String operationType;

      if (widget.cliente == null) {
        success = await vm.addCliente(newCliente);
        operationType = 'creado';
      } else {
        success = await vm.updateCliente(newCliente.idCliente!, newCliente);
        operationType = 'actualizado';
      }

      if (!mounted) return;

      if (success) {
        setState(() => _primaryColor = Colors.green.shade600);
        await Future.delayed(const Duration(milliseconds: 300));

        showNotificationToast(
          context,
          message: 'Cliente $operationType exitosamente',
          type: NotificationType.success,
        );

        if (widget.cliente == null) {
          _limpiarFormulario();
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) setState(() => _primaryColor = Colors.teal.shade400);
          });
        } else {
          Navigator.pop(context, true);
        }
      } else {
        showNotificationToast(
          context,
          message: vm.errorMessage ?? 'Error guardando cliente',
          type: NotificationType.error,
        );
      }
    } catch (e) {
      showNotificationToast(
        context,
        message: 'Error inesperado: ${e.toString()}',
        type: NotificationType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildFormContent(bool isWideScreen, double verticalSpacing) {
    return Column(
      children: [
        DropdownField(
          labelText: 'Tipo de Cliente',
          isDark: false,
          primaryColor: _primaryColor,
          surfaceColor: Colors.white,
          onSurfaceColor: Colors.black87,
          items: const [
            DropdownMenuItem(value: 'persona', child: Text('Persona Natural')),
            DropdownMenuItem(value: 'empresa', child: Text('Empresa')),
          ],
          value: tipoCliente,
          onChanged: (val) => setState(() => tipoCliente = val),
          validator: (val) => val == null || val.isEmpty ? 'Seleccione un tipo de cliente' : null,
          prefixIconData: Icons.business,
        ),
        SizedBox(height: verticalSpacing),

        TextFieldWidget(
          controller: nombreController,
          isDark: false,
          primaryColor: _primaryColor,
          surfaceColor: Colors.white,
          onSurfaceColor: Colors.black87,
          labelText: 'Nombre',
          prefixIconData: Icons.person,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Por favor ingresa el nombre';
            if (value.length < 3) return 'Mínimo 3 caracteres';
            return null;
          },
        ),
        SizedBox(height: verticalSpacing),

        if (tipoCliente == 'persona') ...[
          TextFieldWidget(
            controller: apellidoController,
            isDark: false,
            primaryColor: _primaryColor,
            surfaceColor: Colors.white,
            onSurfaceColor: Colors.black87,
            labelText: 'Apellido',
            prefixIconData: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Por favor ingresa el apellido';
              if (value.length < 3) return 'Mínimo 3 caracteres';
              return null;
            },
          ),
          SizedBox(height: verticalSpacing),
        ],

        if (tipoCliente == 'empresa') ...[
          TextFieldWidget(
            controller: razonSocialController,
            isDark: false,
            primaryColor: _primaryColor,
            surfaceColor: Colors.white,
            onSurfaceColor: Colors.black87,
            labelText: 'Razón Social',
            prefixIconData: Icons.apartment,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Por favor ingresa la razón social';
              if (value.length < 3) return 'Mínimo 3 caracteres';
              return null;
            },
          ),
          SizedBox(height: verticalSpacing),
        ],

        if (tipoCliente != null) ...[
          TextFieldWidget(
            controller: documentoIdentidadController,
            isDark: false,
            primaryColor: _primaryColor,
            surfaceColor: Colors.white,
            onSurfaceColor: Colors.black87,
            labelText: tipoCliente == 'empresa' ? 'Documento (RUC)' : 'Documento (DNI)',
            keyboardType: TextInputType.number,
            prefixIconData: Icons.badge,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Por favor ingresa el documento';
              if (tipoCliente == 'empresa' && value.length != 11) return 'El RUC debe tener 11 dígitos';
              if (tipoCliente == 'persona' && value.length != 8) return 'El DNI debe tener 8 dígitos';
              return null;
            },
          ),
          SizedBox(height: verticalSpacing),
        ],

        TextFieldWidget(
          controller: telefonoController,
          isDark: false,
          primaryColor: _primaryColor,
          surfaceColor: Colors.white,
          onSurfaceColor: Colors.black87,
          labelText: 'Teléfono',
          keyboardType: TextInputType.phone,
          prefixIconData: Icons.phone,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Por favor ingresa el teléfono';
            if (value.length < 9) return 'Mínimo 9 caracteres';
            return null;
          },
        ),
        SizedBox(height: verticalSpacing),

        TextFieldWidget(
          controller: correoController,
          isDark: false,
          primaryColor: _primaryColor,
          surfaceColor: Colors.white,
          onSurfaceColor: Colors.black87,
          labelText: 'Correo',
          keyboardType: TextInputType.emailAddress,
          prefixIconData: Icons.email,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Por favor ingresa el correo';
            if (!value.contains('@') || !value.contains('.')) return 'Ingresa un correo válido';
            return null;
          },
        ),
        SizedBox(height: verticalSpacing),

        TextFieldWidget(
          controller: direccionController,
          isDark: false,
          primaryColor: _primaryColor,
          surfaceColor: Colors.white,
          onSurfaceColor: Colors.black87,
          labelText: 'Dirección',
          prefixIconData: Icons.location_on,
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Por favor ingresa la dirección';
            if (value.length < 10) return 'Mínimo 10 caracteres';
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: widget.cliente == null ? 'Nuevo Cliente' : 'Editar Cliente',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final bool isWideScreen = screenWidth > 600;
          final double paddingValue = screenWidth * 0.03;
          final double verticalSpacing = screenHeight * 0.015;
          final double formPadding = screenWidth * 0.02;
          final double buttonFontSize = isWideScreen ? 16 : 14;
          final double buttonVerticalPadding = screenHeight * 0.02;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: paddingValue,
                    vertical: 16,
                  ),
                  child: Form(
                    key: _formKey,

                      child: isWideScreen
                          ? GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: verticalSpacing,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: screenWidth > 800 ? 4 : 3,
                        children: [
                          DropdownField(
                            labelText: 'Tipo de Cliente',
                            isDark: false,
                            primaryColor: _primaryColor,
                            surfaceColor: Colors.white,
                            onSurfaceColor: Colors.black87,
                            items: const [
                              DropdownMenuItem(value: 'persona', child: Text('Persona Natural')),
                              DropdownMenuItem(value: 'empresa', child: Text('Empresa')),
                            ],
                            value: tipoCliente,
                            onChanged: (val) => setState(() => tipoCliente = val),
                            validator: (val) => val == null || val.isEmpty ? 'Seleccione un tipo de cliente' : null,
                            prefixIconData: Icons.business,
                          ),

                          if (tipoCliente != null)
                            TextFieldWidget(
                              controller: documentoIdentidadController,
                              isDark: false,
                              primaryColor: _primaryColor,
                              surfaceColor: Colors.white,
                              onSurfaceColor: Colors.black87,
                              labelText: tipoCliente == 'empresa' ? 'Documento (RUC)' : 'Documento (DNI)',
                              keyboardType: TextInputType.number,
                              prefixIconData: Icons.badge,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Por favor ingresa el documento';
                                if (tipoCliente == 'empresa' && value.length != 11) return 'El RUC debe tener 11 dígitos';
                                if (tipoCliente == 'persona' && value.length != 8) return 'El DNI debe tener 8 dígitos';
                                return null;
                              },
                            ),

                          TextFieldWidget(
                            controller: nombreController,
                            isDark: false,
                            primaryColor: _primaryColor,
                            surfaceColor: Colors.white,
                            onSurfaceColor: Colors.black87,
                            labelText: 'Nombre',
                            prefixIconData: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Por favor ingresa el nombre';
                              if (value.length < 3) return 'Mínimo 3 caracteres';
                              return null;
                            },
                          ),

                          TextFieldWidget(
                            controller: telefonoController,
                            isDark: false,
                            primaryColor: _primaryColor,
                            surfaceColor: Colors.white,
                            onSurfaceColor: Colors.black87,
                            labelText: 'Teléfono',
                            keyboardType: TextInputType.phone,
                            prefixIconData: Icons.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Por favor ingresa el teléfono';
                              if (value.length < 9) return 'Mínimo 9 caracteres';
                              return null;
                            },
                          ),

                          if (tipoCliente == 'persona')
                            TextFieldWidget(
                              controller: apellidoController,
                              isDark: false,
                              primaryColor: _primaryColor,
                              surfaceColor: Colors.white,
                              onSurfaceColor: Colors.black87,
                              labelText: 'Apellido',
                              prefixIconData: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Por favor ingresa el apellido';
                                if (value.length < 3) return 'Mínimo 3 caracteres';
                                return null;
                              },
                            ),

                          if (tipoCliente == 'empresa')
                            TextFieldWidget(
                              controller: razonSocialController,
                              isDark: false,
                              primaryColor: _primaryColor,
                              surfaceColor: Colors.white,
                              onSurfaceColor: Colors.black87,
                              labelText: 'Razón Social',
                              prefixIconData: Icons.apartment,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Por favor ingresa la razón social';
                                if (value.length < 3) return 'Mínimo 3 caracteres';
                                return null;
                              },
                            ),

                          TextFieldWidget(
                            controller: correoController,
                            isDark: false,
                            primaryColor: _primaryColor,
                            surfaceColor: Colors.white,
                            onSurfaceColor: Colors.black87,
                            labelText: 'Correo',
                            keyboardType: TextInputType.emailAddress,
                            prefixIconData: Icons.email,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Por favor ingresa el correo';
                              if (!value.contains('@') || !value.contains('.')) return 'Ingresa un correo válido';
                              return null;
                            },
                          ),

                          TextFieldWidget(
                            controller: direccionController,
                            isDark: false,
                            primaryColor: _primaryColor,
                            surfaceColor: Colors.white,
                            onSurfaceColor: Colors.black87,
                            labelText: 'Dirección',
                            prefixIconData: Icons.location_on,
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Por favor ingresa la dirección';
                              if (value.length < 10) return 'Mínimo 10 caracteres';
                              return null;
                            },
                          ),
                        ],
                      )
                          : _buildFormContent(isWideScreen, verticalSpacing),
                    ),
                  ),
                ),

              Padding(
                padding: EdgeInsets.all(paddingValue),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      padding: EdgeInsets.symmetric(vertical: buttonVerticalPadding),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      width: 24,
                      height: 34,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                        : Text(
                      widget.cliente == null ? 'GUARDAR CLIENTE' : 'ACTUALIZAR CLIENTE',
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}