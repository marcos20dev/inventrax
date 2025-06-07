import 'package:flutter/material.dart';

class DropdownField extends StatefulWidget {
  final String labelText;
  final bool isDark;
  final Color primaryColor;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final List<DropdownMenuItem<String>> items;
  final String? value;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final IconData? prefixIconData;
  final bool enabled;

  const DropdownField({
    Key? key,
    required this.labelText,
    required this.isDark,
    required this.primaryColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.prefixIconData,
    this.enabled = true,
  }) : super(key: key);

  @override
  _DropdownFieldState createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant DropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selectedValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: widget.onSurfaceColor.withOpacity(0.6),
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,  // <-- para que ocupe todo el ancho disponible

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
          child: DropdownButtonFormField<String>(
            value: _selectedValue,
            items: widget.items,
            onChanged: widget.enabled
                ? (value) {
              setState(() => _selectedValue = value);
              if (widget.onChanged != null) widget.onChanged!(value);
            }
                : null,
            validator: widget.validator,
            decoration: InputDecoration(
              hintText: 'Seleccione ${widget.labelText.toLowerCase()}',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: widget.onSurfaceColor.withOpacity(0.4),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: widget.surfaceColor,
              contentPadding: const EdgeInsets.symmetric( horizontal: 20,
                vertical: 12,),
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
            ),
            iconEnabledColor: widget.primaryColor,
            dropdownColor: widget.surfaceColor,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.enabled
                  ? widget.onSurfaceColor
                  : widget.onSurfaceColor.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }
}
