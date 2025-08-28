// lib/view/screens/appointments/widgets/appointment_step_layout.dart
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class AppointmentStepLayout extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget content;

  const AppointmentStepLayout({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal:18 , vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          
          // Icono con diseño premium
          Center(
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accentColor.withOpacity(0.15),
                        AppColors.accentColor.withOpacity(0.03),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.accentColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentColor.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 42,
                    color: AppColors.accentColor,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Título elegante
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textColor,
                letterSpacing: -0.3,
                height: 1.2,
              ),
            ),
          ),
          
          // Subtítulo refinado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textLightColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Separador elegante
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 28),
          content,
        ],
      ),
    );
  }
}