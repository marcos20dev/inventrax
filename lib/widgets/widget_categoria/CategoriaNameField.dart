import 'package:flutter/material.dart';

class CategoriaNameField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color primaryColor;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final List<String> categoriasSugeridas;
  final void Function(String) onCategoriaSelected;
  final Widget? suffixWidget;

  // Nuevos parámetros para textos
  final String labelText;
  final String suggestionsLabelText;

  const CategoriaNameField({
    Key? key,
    required this.controller,
    required this.isDark,
    required this.primaryColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
    required this.categoriasSugeridas,
    required this.onCategoriaSelected,
    this.suffixWidget,
    this.labelText = 'NOMBRE DE CATEGORÍA',           // valor por defecto
    this.suggestionsLabelText = 'SUGERENCIAS',         // valor por defecto
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget? suffixIconToShow = suffixWidget;
    if (suffixIconToShow == null) {
      suffixIconToShow = controller.text.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Icon(
          controller.text.length > 2
              ? Icons.check_circle_rounded
              : Icons.error_outline_rounded,
          color: controller.text.length > 2
              ? Colors.green.shade400
              : Colors.orange.shade400,
          size: 24,
        ),
      )
          : null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: theme.textTheme.labelSmall?.copyWith(
            color: onSurfaceColor.withOpacity(0.6),
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            cursorColor: Colors.green,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: onSurfaceColor,
            ),
            decoration: InputDecoration(
              hintText: 'Ej: Electrónica...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: onSurfaceColor.withOpacity(0.4),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: surfaceColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(right: 12, left: 0),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.category_rounded,
                  color: surfaceColor,
                  size: 22,
                ),
              ),
              suffixIcon: suffixIconToShow,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa un nombre';
              }
              if (value.length < 3) {
                return 'Mínimo 3 caracteres';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 28),
        Text(
          suggestionsLabelText,
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
          children: categoriasSugeridas.map((categoria) {
            final isSelected = controller.text == categoria;
            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onCategoriaSelected(categoria),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                  categoria,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected ? surfaceColor : onSurfaceColor.withOpacity(0.8),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
