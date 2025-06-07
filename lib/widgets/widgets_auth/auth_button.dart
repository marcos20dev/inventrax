import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;  // <-- aquí es nullable
  final Color backgroundColor;
  final double borderRadius;
  final double height;
  final bool isLoading;
  final Color textColor;
  final double elevation;

  const AuthButton({
    Key? key,
    required this.text,
    this.onPressed,  // cambia aquí a opcional también
    this.backgroundColor = Colors.blue,
    this.borderRadius = 8,
    this.height = 48,
    this.isLoading = false,
    this.textColor = Colors.white,
    this.elevation = 4,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton(
        key: ValueKey<bool>(isLoading),
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          minimumSize: Size(double.infinity, height),
          shadowColor:Colors.teal.shade400,
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textColor,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}
