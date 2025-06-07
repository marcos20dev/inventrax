import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- IMPORTANTE para InputFormatters

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final Color borderColor;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final String? hintText;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;  // <-- nuevo parámetro opcional

  const AuthTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.borderColor = const Color(0xFF263238),
    this.keyboardType = TextInputType.text,
    this.validator,
    this.hintText,
    this.prefixIcon,
    this.inputFormatters,  // <-- nuevo parámetro
  }) : super(key: key);

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: color, width: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,  // <-- aquí lo pasas
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        enabledBorder: _buildBorder(borderColor.withOpacity(0.6)),
        focusedBorder: _buildBorder(borderColor),
        errorBorder: _buildBorder(Colors.red),
        focusedErrorBorder: _buildBorder(Colors.red),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        prefixIcon: prefixIcon,
      ),
      cursorColor: borderColor,
    );
  }
}
