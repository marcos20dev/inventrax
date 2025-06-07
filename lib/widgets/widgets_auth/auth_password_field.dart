import 'package:flutter/material.dart';

class AuthPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final Color borderColor;
  final Widget? prefixIcon;  // Nuevo parámetro opcional para icono al inicio

  const AuthPasswordField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.validator,
    this.borderColor = const Color(0xFF263238),
    this.prefixIcon,  // Opcional, puede ser null
  }) : super(key: key);

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _isVisible = false;

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: color, width: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: !_isVisible,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        labelStyle: TextStyle(color: Colors.grey.shade700),          // color label normal
        enabledBorder: _buildBorder(widget.borderColor.withOpacity(0.6)),
        floatingLabelStyle: TextStyle(color: widget.borderColor),   // color label cuando flota (focused)
        border: _buildBorder(widget.borderColor),
        focusedBorder: _buildBorder(widget.borderColor),
        errorBorder: _buildBorder(Colors.red),
        focusedErrorBorder: _buildBorder(Colors.red),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        prefixIcon: widget.prefixIcon,  // Aquí usamos el prefixIcon solo si no es null
        suffixIcon: IconButton(
          icon: Icon(
            _isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[600],
          ),
          onPressed: _toggleVisibility,
        ),
      ),
    );
  }
}
