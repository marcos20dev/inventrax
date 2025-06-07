import 'package:flutter/material.dart';

import '../../../widgets/widget_producto/DropdownField.dart';

class MovimientoInventarioSection extends StatefulWidget {
  final void Function(String?)? onMotivoChanged;

  final double fieldSpacing;
  final Color primaryColor;
  final Color surfaceColor;
  final Color onSurfaceColor;

  const MovimientoInventarioSection({
    super.key,
    this.onMotivoChanged,
    required this.fieldSpacing,
    required this.primaryColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
  });

  @override
  _MovimientoInventarioSectionState createState() => _MovimientoInventarioSectionState();
}

class _MovimientoInventarioSectionState extends State<MovimientoInventarioSection> {
  String motivoValue = 'stock_inicial';
  String destinatarioValue = 'almacen_central';

  final List<DropdownMenuItem<String>> motivoItems = const [
    DropdownMenuItem(value: 'stock_inicial', child: Text('Stock inicial')),
  ];

  final List<DropdownMenuItem<String>> destinatarioItems = const [
    DropdownMenuItem(value: 'almacen_central', child: Text('Almacén Central')),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Movimiento de Inventario',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
        ),
        SizedBox(height: widget.fieldSpacing),

        DropdownField(
          labelText: 'Motivo',
          isDark: false,
          primaryColor: widget.primaryColor,
          surfaceColor: widget.surfaceColor,
          onSurfaceColor: widget.onSurfaceColor,
          prefixIconData: Icons.assignment,
          value: motivoValue,
          items: motivoItems,
          onChanged: (val) {
            setState(() {
              motivoValue = val ?? 'stock_inicial';
            });
            if (widget.onMotivoChanged != null) {
              widget.onMotivoChanged!(val);
            }
          },
        ),
        SizedBox(height: widget.fieldSpacing),

        DropdownField(
          labelText: 'Destinatario',
          isDark: false,
          primaryColor: widget.primaryColor,
          surfaceColor: widget.surfaceColor,
          onSurfaceColor: widget.onSurfaceColor,
          prefixIconData: Icons.location_on,
          value: destinatarioValue,
          items: destinatarioItems,
          onChanged: (val) {
            setState(() {
              destinatarioValue = val ?? 'almacen_central';
            });
          },
        ),
      ],
    );
  }
}
