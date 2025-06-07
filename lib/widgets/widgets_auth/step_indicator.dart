import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int stepIndex;
  final int currentStep;
  final String label;
  final Color primaryColor;
  final Color darkColor;
  final bool? hasWarning;  // Parámetro opcional, nullable

  const StepIndicator({
    Key? key,
    required this.stepIndex,
    required this.currentStep,
    required this.label,
    required this.primaryColor,
    required this.darkColor,
    this.hasWarning,  // opcional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isActive = currentStep == stepIndex;
    final bool isCompleted = currentStep > stepIndex;

    Color bgColor;
    Widget innerContent;

    if (hasWarning == true) {
      // Mostrar color naranja y icono de advertencia si hasWarning es true
      bgColor = Colors.orange;
      innerContent = const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.white);
    } else if (isCompleted) {
      bgColor = primaryColor;
      innerContent = const Icon(Icons.check, size: 16, color: Colors.white);
    } else {
      bgColor = isActive ? primaryColor : Colors.grey[300]!;
      innerContent = Text(
        '${stepIndex + 1}',
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(child: innerContent),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? darkColor : Colors.grey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: isCompleted
                  ? primaryColor
                  : (isActive ? primaryColor : Colors.grey[300]!),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
