import 'package:flutter/material.dart';

class CategoriaActionButton extends StatelessWidget {
  final bool isEditing;
  final bool isSubmitting;
  final Color primaryColor;
  final Color onSurfaceColor;
  final VoidCallback onPressed;
  final bool isSmallScreen;
  final String label;

  const CategoriaActionButton({
    Key? key,
    required this.isEditing,
    required this.isSubmitting,
    required this.primaryColor,
    required this.onSurfaceColor,
    required this.onPressed,
    required this.isSmallScreen,
    this.label = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonText = label.isNotEmpty
        ? label
        : isEditing ? 'GUARDAR CAMBIOS' : 'CREAR CATEGORÍA';

    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(isSubmitting ? 0.2 : 0.3),
              blurRadius: isSubmitting ? 6 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 16 : 20,
              horizontal: isSmallScreen ? 12 : 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
            ),
            backgroundColor: primaryColor,
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          onPressed: isSubmitting ? null : onPressed,
          child: isSubmitting
              ? SizedBox(
            width: isSmallScreen ? 20 : 24,
            height: isSmallScreen ? 20 : 24,
            child: CircularProgressIndicator(
              strokeWidth: isSmallScreen ? 2.0 : 2.5,
              color: onSurfaceColor,
            ),
          )
              : Text(
            buttonText,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 15,
              fontWeight: FontWeight.w700,
              color: onSurfaceColor,
              letterSpacing: isSmallScreen ? 0.5 : 0.8,
            ),
          ),
        ),
      ),
    );
  }
}