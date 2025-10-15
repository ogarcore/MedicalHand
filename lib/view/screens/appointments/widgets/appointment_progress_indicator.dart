// lib/view/screens/appointments/widgets/appointment_progress_indicator.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'progress_step_widget.dart'; // 1. Importa el nuevo widget

class AppointmentProgressIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> stepTitles;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showStepNumbers;
  final bool showProgressText;

  const AppointmentProgressIndicator({
    super.key,
    required this.currentStep,
    this.stepTitles = const ['ubicacion', 'hospital', 'motivo'],
    this.activeColor,
    this.inactiveColor,
    this.showStepNumbers = true,
    this.showProgressText = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveActiveColor =
        activeColor ?? AppColors.accentColor(context);
    final Color effectiveInactiveColor = inactiveColor ?? Colors.grey[300]!;
    final int totalSteps = stepTitles.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final double availableWidth = constraints.maxWidth;
              final double stepWidth = availableWidth / totalSteps;

              return Stack(
                children: [
                  // Línea de fondo
                  Positioned(
                    top: 22,
                    left: stepWidth / 2,
                    right: stepWidth / 2,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: effectiveInactiveColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Línea de progreso activa
                  Positioned(
                    top: 22,
                    left: stepWidth / 2,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                      height: 4,
                      width: (stepWidth * currentStep).clamp(
                        0.0,
                        availableWidth - stepWidth,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: effectiveActiveColor,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(totalSteps, (index) {
                      return ProgressStepWidget(
                        // 2. Usamos el widget refactorizado
                        stepNumber: index + 1,
                        title: stepTitles[index].tr(),
                        isActive: index <= currentStep,
                        isCompleted: index < currentStep,
                        stepWidth: stepWidth,
                        activeColor: effectiveActiveColor,
                        inactiveColor: effectiveInactiveColor,
                        showStepNumbers: showStepNumbers,
                      );
                    }),
                  ),
                ],
              );
            },
          ),

          if (showProgressText) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: effectiveActiveColor.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    HugeIcons.strokeRoundedCovidInfo,
                    size: 16,
                    color: effectiveActiveColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'paso_de'.tr(
                      namedArgs: {
                        'currentStep': (currentStep + 1).toString(),
                        'totalSteps': totalSteps.toString(),
                      },
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: effectiveActiveColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
