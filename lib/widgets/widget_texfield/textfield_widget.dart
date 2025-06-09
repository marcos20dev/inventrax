import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final int maxLines;
  final bool isDark;
  final Color primaryColor;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final String labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final Widget? suffixWidget;
  final Widget? prefixIcon;       // Para icono personalizado (Widget)
  final IconData? prefixIconData; // Para icono simple (IconData)
  final String? Function(String?)? validator;
  final bool enabled;
  final bool showLabel;
  final int? minLength;
  final int? maxLength;
  final bool required;
  final String? customErrorMessage;
  final List<String>? suggestions; // Para lista de sugerencias (ej: categorías)
  final void Function(String)? onSuggestionSelected;

  // Nuevas propiedades para control de foco y acciones teclado

  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  // NUEVO parámetro opcional onChanged
  final void Function(String)? onChanged;

  // NUEVO parámetro para mostrar/ocultar icono validación (check/error)
  final bool showValidationIcon;

  const TextFieldWidget({
    Key? key,
    required this.controller,
    this.maxLines = 1,
    required this.isDark,
    required this.primaryColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
    this.labelText = 'Texto',
    this.hintText,
    this.keyboardType,
    this.suffixWidget,
    this.prefixIcon,
    this.prefixIconData,
    this.validator,
    this.enabled = true,
    this.showLabel = true,
    this.minLength,
    this.maxLength,
    this.required = true,
    this.customErrorMessage,
    this.suggestions,
    this.onSuggestionSelected,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.showValidationIcon = true, // valor por defecto true
  }) : super(key: key);

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late TextEditingController _controller;
  String? _selectedSuggestion;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  String? _defaultValidator(String? value) {
    if (widget.required && (value == null || value.isEmpty)) {
      return widget.customErrorMessage ?? 'Por favor ingresa ${widget.labelText.toLowerCase()}';
    }

    if (widget.minLength != null && value != null && value.length < widget.minLength!) {
      return widget.customErrorMessage ??
          'Mínimo ${widget.minLength} ${widget.minLength == 1 ? 'carácter' : 'caracteres'}';
    }

    if (widget.maxLength != null && value != null && value.length > widget.maxLength!) {
      return widget.customErrorMessage ??
          'Máximo ${widget.maxLength} ${widget.maxLength == 1 ? 'carácter' : 'caracteres'}';
    }

    if (widget.keyboardType == TextInputType.emailAddress && value != null && value.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) return 'Ingresa un correo electrónico válido';
    }

    if (widget.keyboardType == TextInputType.phone && value != null && value.isNotEmpty) {
      final phoneRegex = RegExp(r'^[0-9]{9,15}$');
      if (!phoneRegex.hasMatch(value)) return 'Ingresa un número de teléfono válido';
    }

    if (widget.keyboardType == TextInputType.number && value != null && value.isNotEmpty) {
      final numberRegex = RegExp(r'^[0-9]+$');
      if (!numberRegex.hasMatch(value)) return 'Ingresa solo números';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = _controller.text.isNotEmpty;
    final isValid = hasText && (widget.validator?.call(_controller.text) ?? _defaultValidator(_controller.text)) == null;

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
        if (widget.showLabel) const SizedBox(height: 0),

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
            controller: _controller,
            maxLines: widget.maxLines,
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            maxLength: widget.maxLength,
            cursorColor: widget.primaryColor,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.enabled
                  ? widget.onSurfaceColor
                  : widget.onSurfaceColor.withOpacity(0.4),
            ),

            // Aquí se agrega onChanged
            onChanged: widget.onChanged,

            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,

            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Ingresa ${widget.labelText.toLowerCase()}...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: widget.onSurfaceColor.withOpacity(0.4),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: widget.surfaceColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              prefixIcon: widget.prefixIcon != null
                  ? Container(
                margin: const EdgeInsets.only(left: 0, right: 0),
                decoration: BoxDecoration(
                  color: widget.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(8),
                child: widget.prefixIcon,
              )
                  : (widget.prefixIconData == null
                  ? null
                  : Container(
                margin: const EdgeInsets.only(left: 0, right: 0),
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
              )),
              suffixIcon: widget.showValidationIcon
                  ? (widget.suffixWidget ??
                  (hasText
                      ? Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      isValid ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                      color: isValid ? Colors.green.shade400 : Colors.orange.shade400,
                      size: 24,
                    ),
                  )
                      : null))
                  : widget.suffixWidget,
              counterText: '',
            ),

            validator: widget.validator ?? _defaultValidator,
          ),
        ),

        if (widget.suggestions != null && widget.suggestions!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'SUGERENCIAS',
            style: theme.textTheme.labelSmall?.copyWith(
              color: widget.onSurfaceColor.withOpacity(0.6),
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.suggestions!.map((s) {
              final isSelected = _controller.text == s;
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  _controller.text = s;
                  if (widget.onSuggestionSelected != null) widget.onSuggestionSelected!(s);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? widget.primaryColor : widget.surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: widget.onSurfaceColor.withOpacity(0.1),
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
                    s,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected ? widget.surfaceColor : widget.onSurfaceColor.withOpacity(0.8),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
