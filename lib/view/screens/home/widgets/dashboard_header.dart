import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  // Función para obtener saludo según la hora
  String _getGreeting(int hour) {
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '¡$greeting!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor(context),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '¿Cómo te podemos ayudar hoy?',
          style: TextStyle(
            fontSize: 16, 
            color: AppColors.textLightColor(context)
          ),
        ),
      ],
    );
  }
}