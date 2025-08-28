// lib/view/screens/appointments/widgets/appointment_navigation_bar.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class AppointmentNavigationBar extends StatelessWidget {
  final int currentStep;
  final VoidCallback onNextPressed;
  final VoidCallback onPreviousPressed;

  const AppointmentNavigationBar({
    super.key,
    required this.currentStep,
    required this.onNextPressed,
    required this.onPreviousPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (currentStep > 0)
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 45,
                  child: OutlinedButton(
                    onPressed: onPreviousPressed,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(
                        color: AppColors.accentColor,
                        width: 0.8,
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          HugeIcons.strokeRoundedArrowLeft01,
                          size: 18,
                          color: AppColors.accentColor,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Atrás',
                          style: TextStyle(
                            color: AppColors.accentColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (currentStep > 0) const SizedBox(width: 16),
            Expanded(
              flex: currentStep == 0 ? 1 : 2,
              child: SizedBox(
                height: 45,
                child: ElevatedButton(
                  onPressed: onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.accentColor.withOpacity(0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentStep < 2 ? 'Continuar' : 'Ver resumen',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      if (currentStep < 2) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          HugeIcons.strokeRoundedArrowRight01,
                          size: 20,
                          color: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}