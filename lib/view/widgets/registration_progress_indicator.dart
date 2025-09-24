import 'package:flutter/material.dart';
import '../../../app/core/constants/app_colors.dart';

class RegistrationProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const RegistrationProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paso $currentStep de $totalSteps',
          style: TextStyle(
            color: AppColors.textColor(context).withAlpha(150),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        // LinearProgressIndicator para la barra de progreso
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: currentStep / totalSteps,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primaryColor(context),
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
