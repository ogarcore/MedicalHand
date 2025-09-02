// lib/view/screens/home/widgets/dashboard_action_buttons.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view/screens/appointments/appointment_options_screen.dart';

class DashboardActionButtons extends StatelessWidget {
  final bool canCheckIn;

  const DashboardActionButtons({super.key, required this.canCheckIn});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // CAMBIO: El botón de confirmar asistencia ahora es condicional
        if (canCheckIn)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(HugeIcons.strokeRoundedTickDouble04, size: 22),
              label: const Text(
                'Confirmar asistencia y recibir turno',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                // Lógica para el check-in
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: AppColors.primaryColor.withAlpha(200),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: AppColors.primaryColor.withAlpha(102),
                elevation: 5,
              ),
            ),
          ),
        
        // CAMBIO: El espacio entre botones también es condicional
        if (canCheckIn) const SizedBox(height: 16),

        // El botón de agendar nueva cita siempre se muestra
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(HugeIcons.strokeRoundedLayerAdd, size: 22, color: Colors.white),
            label: const Text(
              'Agendar Nueva Cita',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppointmentOptionsScreen()),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              backgroundColor: AppColors.accentColor.withAlpha(200),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: AppColors.accentColor.withAlpha(102),
              elevation: 5,
              animationDuration: const Duration(milliseconds: 300),
            ),
          ),
        ),
      ],
    );
  }
}