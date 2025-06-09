import 'package:flutter/material.dart';
import 'package:inventrax/views/ventas/venta_detail.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../repositories/cliente_repository.dart';
import '../../repositories/producto_repository.dart';
import '../../repositories/venta_repository.dart';
import '../../services/ChangeNotifier.dart';
import '../../viewmodels/venta/registro_venta_viewmodel.dart';
import '../../viewmodels/venta/venta_viewmodel.dart';
import '../../widgets/widget_drawer/base_scaffold.dart';
import '../../widgets/widget_notification/Notification_Toast.dart';
import '../../widgets/widget_producto/ScannerWidget.dart';
import '../../widgets/widget_texfield/textfield_widget.dart';
import 'ScannerVentaWidget.dart';

class VentasFormScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  bool _hasUnfocusedOnce = false;

  VentasFormScreen({Key? key}) : super(key: key);
  void _mostrarDialogoEditarProducto(BuildContext context, VentasViewModel ventasVM, int index, Map<String, dynamic> producto) {
    final TextEditingController cantidadEditarController = TextEditingController(text: producto['cantidad'].toString());
    final FocusNode _cantidadFocus = FocusNode();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,  // Fondo blanco fijo
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con icono y título responsivo
                Row(
                  children: [
                    Icon(Icons.edit_rounded, color: Colors.teal.shade400, size: 24),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Editar ${producto['nombre']}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,  // Trunca si es muy largo
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Campo de texto para cantidad
                Text(
                  'Cantidad',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: cantidadEditarController,
                    focusNode: _cantidadFocus,
                    keyboardType: TextInputType.number,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      isDense: true,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.teal.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 4,
                        shadowColor: Colors.teal.shade200,
                      ),
                      onPressed: () {
                        final nuevaCantidad = int.tryParse(cantidadEditarController.text);
                        if (nuevaCantidad != null && nuevaCantidad > 0) {
                          ventasVM.productos[index]['cantidad'] = nuevaCantidad;
                          ventasVM.notifyListeners();
                          Navigator.of(context).pop();
                        } else {
                          cantidadEditarController.clear();
                          _cantidadFocus.requestFocus();
                        }
                      },
                      child: const Text('Guardar Cambios'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final Color _primaryColor = Colors.teal.shade400;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => VentasViewModel(
            ClientesRepository(Supabase.instance.client),
            ProductoRepository(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RegistroVentaViewModel(
            VentaRepository(Supabase.instance.client),
          ),
        ),
      ],
      child: Consumer2<VentasViewModel, RegistroVentaViewModel>(
        builder: (context, ventasVM, registroVentaVM, child) {
          ventasVM.onShowToast = (message, type) {
            showNotificationToast(
              context,
              message: message,
              type: type,
              verticalPositionFactor: 0.08,
            );
          };

          return BaseScaffold(
            title: 'Nueva Venta',
            backgroundColor: const Color(0xFFF5F5F5),
            body: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Información del Cliente', _primaryColor),
                      const SizedBox(height: 5),
                      Card(
                        color: Colors.teal.shade50.withOpacity(0.2),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.teal.shade400.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                'Ingrese RUC (11 dígitos) si es Empresa o DNI (8 dígitos) si es Persona Natural',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: textColor.withOpacity(0.4),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFieldWidget(
                                controller: ventasVM.rucController,
                                isDark: isDark,
                                primaryColor: _primaryColor,
                                surfaceColor: cardColor!,
                                onSurfaceColor: textColor,
                                labelText: 'RUC/DNI',
                                keyboardType: TextInputType.number,
                                prefixIconData: Icons.badge_outlined,
                                maxLength: 11,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Este campo es requerido';
                                  }
                                  if (value.length != 8 && value.length != 11) {
                                    return 'Debe tener 8 o 11 dígitos';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: ventasVM.isLoadingCliente
                                      ? null
                                      : () async {
                                    final input = ventasVM.rucController.text.trim();
                                    if (input.isNotEmpty && (input.length == 8 || input.length == 11)) {
                                      await ventasVM.buscarClientePorDni(input);
                                    } else {
                                      showNotificationToast(
                                        context,
                                        message: 'Ingrese un DNI o RUC válido',
                                        type: NotificationType.warning,
                                      );
                                    }
                                  },
                                  icon: ventasVM.isLoadingCliente
                                      ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : const Icon(Icons.search, color: Colors.white),
                                  label: ventasVM.isLoadingCliente
                                      ? const Text('Buscando...', style: TextStyle(color: Colors.white))
                                      : const Text('Buscar Cliente', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Card(
                                color: Colors.teal.shade50.withOpacity(0.2),
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: _primaryColor.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.badge_outlined,
                                            size: 24,
                                            color: _primaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ventasVM.nombreClienteController.text.isEmpty
                                                    ? 'Cliente'
                                                    : ventasVM.nombreClienteController.text,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: ventasVM.nombreClienteController.text.isEmpty
                                                      ? Colors.grey.shade500
                                                      : Theme.of(context).textTheme.titleMedium?.color,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                ventasVM.correoController.text.isEmpty
                                                    ? 'El cliente debe estar registrado'
                                                    : ventasVM.correoController.text,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: ventasVM.correoController.text.isEmpty
                                                      ? Colors.grey.shade400
                                                      : Colors.grey.shade600,
                                                ),
                                              ),
                                              if (ventasVM.rucController.text.isNotEmpty)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Text(
                                                    'RUC/DNI: ${ventasVM.rucController.text}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey.shade400,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildSectionHeader('Detalle de Productos', _primaryColor),
                      const SizedBox(height: 5),
                      Card(
                        color: Colors.teal.shade50.withOpacity(0.2),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextFieldWidget(
                                controller: ventasVM.codigoBarrasController,

                                isDark: isDark,
                                primaryColor: Colors.teal.shade400,
                                surfaceColor: cardColor,
                                onSurfaceColor: textColor,
                                labelText: 'Código de Barras',
                                keyboardType: TextInputType.number,
                                prefixIcon: Container(
                                  padding: const EdgeInsets.all(2),
                                  child: Image.asset('assets/code1.png', width: 24, height: 24),
                                ),
                                suffixWidget: IconButton(
                                  icon: Image.asset('assets/icon_barras1.png', width: 24, height: 24),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ScannerVentaWidget(viewModel: ventasVM),
                                      ),
                                    );


                                  },
                                ),
                                validator: (_) => null, // explicitamente deshabilita la validacion

                              ),
                              const SizedBox(height: 12),
                              TextFieldWidget(
                                controller: ventasVM.nombreProductoController,
                                isDark: isDark,
                                primaryColor: Colors.teal.shade400,
                                surfaceColor: cardColor,
                                onSurfaceColor: textColor,
                                labelText: 'Producto',
                                hintText: 'Nombre del producto',
                                showValidationIcon: false,  // para ocultar los iconos de validación
                                keyboardType: TextInputType.text,
                                enabled: false,
                                validator: (_) => null, // explicitamente deshabilita la validacion

                              ),
                              const SizedBox(height: 12),
                              TextFieldWidget(
                                controller: ventasVM.descripcionProductoController,
                                isDark: isDark,
                                primaryColor: Colors.teal.shade400,
                                surfaceColor: cardColor,
                                onSurfaceColor: textColor,
                                showValidationIcon: false,  // para ocultar los iconos de validación

                                labelText: 'Descripción',
                                hintText: 'Descripción del producto',
                                keyboardType: TextInputType.text,
                                enabled: false,
                                maxLines: 2,
                                validator: (_) => null, // explicitamente deshabilita la validacion

                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,  // Más espacio para cantidad
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.remove_circle_outline, color: _primaryColor),
                                          onPressed: () {
                                            int current = int.tryParse(ventasVM.cantidadController.text) ?? 1;
                                            if (current > 1) {
                                              current--;
                                              ventasVM.cantidadController.text = current.toString();
                                              ventasVM.actualizarPrecioTotal();
                                            }
                                          },
                                        ),
                                        Expanded(
                                          child: TextFieldWidget(
                                            controller: ventasVM.cantidadController,

                                            isDark: isDark,
                                            primaryColor: _primaryColor,
                                            surfaceColor: cardColor,
                                            onSurfaceColor: textColor,
                                            showValidationIcon: false,  // ocultar iconos validación
                                            labelText: 'Cantidad',
                                            hintText: '00',
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              ventasVM.actualizarPrecioTotal();
                                            },
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.add_circle_outline, color: _primaryColor),
                                          onPressed: () {
                                            int current = int.tryParse(ventasVM.cantidadController.text) ?? 1;
                                            current++;
                                            ventasVM.cantidadController.text = current.toString();
                                            ventasVM.actualizarPrecioTotal();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8), // un poco más de separación

                                  Expanded(
                                    flex: 1,  // Menos espacio para precio
                                    child: TextFieldWidget(
                                      controller: ventasVM.precioController,
                                      isDark: isDark,
                                      primaryColor: _primaryColor,
                                      surfaceColor: cardColor,
                                      onSurfaceColor: textColor,
                                      showValidationIcon: false,  // ocultar iconos validación
                                      labelText: 'Precio',
                                      hintText: 'S/ 0.00',
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      enabled: false,
                                      validator: (_) => null, // explicitamente deshabilita la validacion

                                    ),
                                  ),
                                ],
                              ),


                              const SizedBox(height: 12),
                              TextFieldWidget(
                                controller: ventasVM.precioTotalController,
                                isDark: isDark,
                                primaryColor: _primaryColor,
                                surfaceColor: cardColor,
                                onSurfaceColor: textColor,
                                showValidationIcon: false,  // para ocultar los iconos de validación

                                labelText: 'Sub Total',

                                hintText: 'S/ 0.00',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                enabled: false,
                                suffixWidget: null,
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    color: _primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _primaryColor.withOpacity(0.6),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        ventasVM.agregarProducto();
                                        registroVentaVM.setProductos(List<Map<String, dynamic>>.from(ventasVM.productos));

                                      },
                                      splashColor: Colors.white24,
                                      highlightColor: Colors.white10,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Agregar',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Column(
                        children: [
                          if (ventasVM.productos.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey.withOpacity(0.5)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No hay productos agregados',
                                    style: TextStyle(
                                      color: Colors.grey.withOpacity(0.7),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              children: ventasVM.productos.asMap().entries.map((entry) {
                                final index = entry.key;
                                final p = entry.value;
                                final totalProducto = p['cantidad'] * p['precio'];

                                return Dismissible(
                                  key: Key('$index-${p['nombre']}'),
                                  direction: DismissDirection.horizontal,
                                  confirmDismiss: (direction) async {
                                    if (direction == DismissDirection.endToStart) {
                                      // Deslizar de derecha a izquierda = EDITAR
                                      _mostrarDialogoEditarProducto(context, ventasVM, index, p);
                                      return false; // No se elimina al editar
                                    } else if (direction == DismissDirection.startToEnd) {
                                      // Deslizar de izquierda a derecha = ELIMINAR
                                      final confirmDelete = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Confirmar eliminación'),
                                          content: Text('¿Deseas eliminar ${p['nombre']}?'),
                                          actions: [
                                            TextButton(
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: const Text('Cancelar')),
                                            TextButton(
                                                onPressed: () => Navigator.of(context).pop(true),
                                                child: const Text('Eliminar')),
                                          ],
                                        ),
                                      );
                                      if (confirmDelete ?? false) {
                                        ventasVM.eliminarProducto(index);
                                        return true; // Confirma eliminación
                                      }
                                      return false; // Cancela eliminación
                                    }
                                    return false;
                                  },
                                  // Fondo cuando deslizas de izquierda a derecha (para eliminar)
                                  background: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1), // Rojo para eliminar
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.delete, color: Colors.red),
                                  ),
                                  // Fondo cuando deslizas de derecha a izquierda (para editar)
                                  secondaryBackground: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade400.withOpacity(0.1),
                                    // Azul para editar
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.edit, color: Colors.teal),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: _primaryColor.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.shopping_basket, color: _primaryColor),
                                      ),
                                      title: Text(p['nombre'],
                                          style:
                                          TextStyle(fontWeight: FontWeight.w500, color: textColor)),
                                      subtitle: Text('${p['cantidad']} x S/ ${p['precio'].toStringAsFixed(2)}',
                                          style: TextStyle(color: Colors.grey[600])),
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('S/ ${totalProducto.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: textColor)),
                                          Text('${p['cantidad']} und.',
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                        ],
                                      ),
                                    ),
                                  ),
                                );


                              }).toList(),
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: registroVentaVM.isLoading
                              ? null
                              : () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              if (registroVentaVM.productos.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Agrega al menos un producto'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              final userSession = Provider.of<UserSession>(context, listen: false);
                              final userId = userSession.uid;

                              if (userId == null) {
                                showNotificationToast(
                                  context,
                                  message: 'Usuario no autenticado',
                                  type: NotificationType.error,
                                );
                                return;
                              }

                              // Asignamos el usuario y cliente seleccionado
                              registroVentaVM.idUsuario = userId;
                              registroVentaVM.clienteSeleccionado = ventasVM.clienteSeleccionado;
                              registroVentaVM.setProductos(List<Map<String, dynamic>>.from(ventasVM.productos));

                              // Calculamos el total de la venta
                              double total = ventasVM.productos.fold(0, (sum, producto) {
                                return sum + (producto['cantidad'] * producto['precio']);
                              });

                              // Llamamos a la función para registrar la venta y obtener el idVenta
                              final idVenta = await registroVentaVM.registrarVenta(context);

                              // Si el idVenta se obtuvo, redirigir a los detalles de la venta
                              if (idVenta != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => VentaDetailScreen(idVenta: idVenta)),
                                );
                              }

                              // Restablecemos el formulario
                              ventasVM.resetForm();
                            }
                          },

                          child: registroVentaVM.isLoading
                              ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'REGISTRAR VENTA',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),


                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: null,
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ));
  }
}
