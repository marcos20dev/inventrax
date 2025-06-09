import 'package:flutter/material.dart';
import '../../../widgets/widget_producto/DropdownField.dart';
import '../../../widgets/widget_producto/ProductoTextField.dart';
import '../../../widgets/widget_texfield/textfield_widget.dart';

class ProductoInfoSection extends StatelessWidget {
  final TextEditingController categoriaController;
  final List<DropdownMenuItem<String>> categoriaItems;
  final void Function(String?) onCategoriaChanged;

  final TextEditingController codigoBarrasController;
  final void Function()? onBarcodeScan;

  final TextEditingController nombreController;
  final TextEditingController descripcionController;

  final TextEditingController cantidadController;
  final TextEditingController precioVentaController;
  final String unidadMedida;

  final Color primaryColor;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final double fieldSpacing;
  final bool isSmallScreen;

  final String? Function(String?)? validateCategoria;
  final String? Function(String?)? validateCantidad;
  final String? Function(String?)? validatePrecio;

  const ProductoInfoSection({
    super.key,
    required this.categoriaController,
    required this.categoriaItems,
    required this.onCategoriaChanged,
    required this.codigoBarrasController,
    required this.onBarcodeScan,
    required this.nombreController,
    required this.descripcionController,
    required this.cantidadController,
    required this.precioVentaController,
    required this.unidadMedida,
    required this.primaryColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
    required this.fieldSpacing,
    required this.isSmallScreen,
    this.validateCategoria,
    this.validateCantidad,
    this.validatePrecio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
            'Información del Producto',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700
            )
        ),
        SizedBox(height: fieldSpacing),

        // Categoría
        DropdownField(
          labelText: 'Categoría',
          isDark: false,
          primaryColor: primaryColor,
          surfaceColor: surfaceColor,
          onSurfaceColor: onSurfaceColor,
          prefixIconData: Icons.category,
          value: categoriaController.text.isNotEmpty ? categoriaController.text : null,
          items: categoriaItems,
          onChanged: onCategoriaChanged,
          validator: validateCategoria,
        ),
        SizedBox(height: fieldSpacing),

        // Código de Barras
        TextFieldWidget(
          controller: codigoBarrasController,
          isDark: false,
          primaryColor: Colors.teal.shade400,
          surfaceColor: Colors.white,
          onSurfaceColor: Colors.black87,
          labelText: 'Código de Barras',
          keyboardType: TextInputType.text, // Cambio aquí a TextInputType.text
          prefixIcon: Container(
            padding: EdgeInsets.all(5),
            child: Image.asset('assets/code1.png', width: 24, height: 24),
          ),
          suffixWidget: IconButton(
            icon: Image.asset('assets/icon_barras1.png', width: 24, height: 24),
            onPressed: onBarcodeScan,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa el código de barras';
            }
            // Si deseas realizar alguna validación adicional, como longitud mínima o máxima
            if (value.length < 8) {
              return 'El código de barras debe tener al menos 8 caracteres';
            }
            return null; // No hay error
          },
        ),

        SizedBox(height: fieldSpacing),

        // Nombre del Producto
        TextFieldWidget(
          controller: nombreController,
          isDark: false,
          primaryColor: primaryColor,
          surfaceColor: surfaceColor,
          onSurfaceColor: onSurfaceColor,
          labelText: 'Nombre del Producto',
          prefixIconData: Icons.shopping_bag_rounded,
          validator: (value) => value == null || value.isEmpty ? 'Ingrese el nombre del producto' : null,
        ),
        SizedBox(height: fieldSpacing),

        // Descripción
        TextFieldWidget(
          controller: descripcionController,
          isDark: false,
          primaryColor: primaryColor,
          surfaceColor: surfaceColor,
          onSurfaceColor: onSurfaceColor,
          labelText: 'Descripción',
          prefixIconData: Icons.description_rounded,
          keyboardType: TextInputType.multiline,
          maxLines: isSmallScreen ? 3 : 4,
        ),
        SizedBox(height: fieldSpacing),

        // Cantidad y Precio en paralelo (siempre)
        Row(
          children: [
            Expanded(
              child: TextFieldWidget(
                controller: cantidadController,
                isDark: false,
                primaryColor: primaryColor,
                surfaceColor: surfaceColor,
                onSurfaceColor: onSurfaceColor,
                labelText: 'Cantidad Inicial',
                keyboardType: TextInputType.number,
                prefixIconData: Icons.inventory_2,
                validator: validateCantidad,
              ),
            ),
            SizedBox(width: fieldSpacing),
            Expanded(
              child: TextFieldWidget(
                controller: precioVentaController,
                isDark: false,
                primaryColor: primaryColor,
                surfaceColor: surfaceColor,
                onSurfaceColor: onSurfaceColor,
                labelText: 'Precio de Venta',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Container(
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Text(
                      'S/',
                      style: TextStyle(
                          color: surfaceColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      )
                  ),
                ),
                validator: validatePrecio,
              ),
            ),
          ],
        ),
        SizedBox(height: fieldSpacing),

        // Unidad de Medida (siempre debajo)
        TextFieldWidget(
          controller: TextEditingController(text: unidadMedida),
          isDark: false,
          primaryColor: primaryColor,
          surfaceColor: surfaceColor,
          onSurfaceColor: onSurfaceColor,
          labelText: 'Unidad de Medida',
          prefixIconData: Icons.straighten,
          keyboardType: TextInputType.text,
          maxLines: 1,
          enabled: false,
        ),
      ],
    );
  }
}
