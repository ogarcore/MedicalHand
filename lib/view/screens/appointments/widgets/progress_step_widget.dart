// lib/view/screens/appointments/widgets/progress_step_widget.dart
import 'package:flutter/material.dart';

class ProgressStepWidget extends StatelessWidget {
  final int stepNumber;
  final String title;
  final bool isActive;
  final bool isCompleted;
  final double stepWidth;
  final Color activeColor;
  final Color inactiveColor;
  final bool showStepNumbers;

  const ProgressStepWidget({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.isActive,
    required this.isCompleted,
    required this.stepWidth,
    required this.activeColor,
    required this.inactiveColor,
    required this.showStepNumbers,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: stepWidth,
      child: Column(
        children: [
          // Círculo del paso con animación
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            width: 42, // Ligeramente más grande
            height: 42, // Ligeramente más grande
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted
                    ? activeColor.withOpacity(0.4) // Opacidad ligeramente aumentada
                    : isActive
                        ? activeColor.withOpacity(0.25) // Opacidad ligeramente aumentada
                        : Colors.transparent,
                width: isActive ? 2.5 : 0, // Borde ligeramente más grueso
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: activeColor.withOpacity(0.25), // Opacidad aumentada
                        blurRadius: 8, // Desenfoque aumentado
                        offset: const Offset(0, 3), // Offset ligeramente aumentado
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 22, // Tamaño ligeramente aumentado
                    )
                  : Text(
                      showStepNumbers ? stepNumber.toString() : '',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[700], // Color más oscuro para inactivo
                        fontWeight: FontWeight.w700, // Peso de fuente ligeramente aumentado
                        fontSize: 16,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 10), // Espaciado ligeramente aumentado

          // Texto del paso
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 12.5, // Tamaño de fuente ligeramente aumentado
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, // Peso aumentado para activo
              color: isActive ? activeColor : Colors.grey[700], // Color más oscuro para inactivo
              height: 1.3, // Altura de línea ligeramente aumentada
              letterSpacing: isActive ? 0.1 : 0, // Pequeño espaciado de letras para activo
            ),
            textAlign: TextAlign.center,
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}