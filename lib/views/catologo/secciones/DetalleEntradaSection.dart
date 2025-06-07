import 'package:flutter/material.dart';
import '../../../widgets/widget_producto/DropdownField.dart';
import '../../../widgets/widget_producto/ProductoTextField.dart';
import '../../../widgets/widget_texfield/textfield_widget.dart';

class DetalleEntradaSection extends StatelessWidget {
  final TextEditingController precioCompraController;
  final TextEditingController proveedorController;  // Añadido
  final List<DropdownMenuItem<String>> proveedorItems;  // Añadido
  final ValueChanged<String?> onProveedorChanged;       // Añadido
  final Color primaryColor;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final double fieldSpacing;

  const DetalleEntradaSection({
    super.key,
    required this.precioCompraController,
    required this.proveedorController,
    required this.proveedorItems,
    required this.onProveedorChanged,
    required this.primaryColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
    required this.fieldSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalle de Entrada del Producto',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
        ),
        SizedBox(height: fieldSpacing),

        DropdownField(
          labelText: 'Proveedor',
          isDark: false,
          primaryColor: primaryColor,
          surfaceColor: surfaceColor,
          onSurfaceColor: onSurfaceColor,
          prefixIconData: Icons.local_shipping,
          value: proveedorController.text.isNotEmpty ? proveedorController.text : null,
          items: proveedorItems,
          onChanged: onProveedorChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Seleccione un proveedor';
            }
            return null;
          },
        ),

        SizedBox(height: fieldSpacing),

        TextFieldWidget(
          controller: precioCompraController,
          isDark: false,
          primaryColor: primaryColor,
          surfaceColor: surfaceColor,
          onSurfaceColor: onSurfaceColor,
          labelText: 'Precio de Compra',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIcon: Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(2),
            child: Text(
              'S/',
              style: TextStyle(
                color: surfaceColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Ingrese precio';
            if (double.tryParse(value) == null) return 'Ingrese un número válido';
            return null;
          },
        ),
      ],
    );
  }
}
