import 'package:flutter/material.dart';

class ProductoTextField extends StatefulWidget {
  final int maxLines;
  final TextEditingController controller;
  final bool isDark;
  final Color primaryColor;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final String labelText;
  final TextInputType? keyboardType;
  final Widget? suffixWidget;
  final Widget? prefixIcon;       // Nuevo: widget para ícono personalizado
  final IconData? prefixIconData; // Ícono tradicional con IconData
  final String? Function(String?)? validator;
  final bool enabled;
  final bool showLabel;  // <-- Nuevo parámetro para controlar la etiqueta

  const ProductoTextField({
    Key? key,
    required this.controller,
    required this.isDark,
    required this.primaryColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
    this.labelText = 'Texto',
    this.keyboardType,
    this.suffixWidget,
    this.prefixIcon,
    this.prefixIconData,
    this.maxLines = 1,
    this.validator,
    this.enabled = true,
    this.showLabel = true,  // Por defecto muestra label
  }) : super(key: key);

  @override
  _ProductoTextFieldState createState() => _ProductoTextFieldState();
}

class _ProductoTextFieldState extends State<ProductoTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleTextChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel)
          Text(
            widget.labelText.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: widget.onSurfaceColor.withOpacity(0.6),
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (widget.showLabel) const SizedBox(height: 6),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            cursorColor: widget.primaryColor,
            enabled: widget.enabled,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.enabled
                  ? widget.onSurfaceColor
                  : widget.onSurfaceColor.withOpacity(0.4),
            ),
            decoration: InputDecoration(
              hintText: 'Ingresa ${widget.labelText.toLowerCase()}...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: widget.onSurfaceColor.withOpacity(0.4),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: widget.surfaceColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 1,
                vertical: 8,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Container(
                margin: const EdgeInsets.only(right: 0, left: 0),
                decoration: BoxDecoration(
                  color: widget.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: widget.prefixIcon,
              )
                  : widget.prefixIconData == null
                  ? null
                  : Container(
                margin: const EdgeInsets.only(right: 0, left: 0),
                decoration: BoxDecoration(
                  color: widget.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(
                  widget.prefixIconData,
                  color: widget.surfaceColor,
                  size: 22,
                ),
              ),
              suffixIcon: widget.suffixWidget,  // Aquí no hay iconos extras
            ),
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}
