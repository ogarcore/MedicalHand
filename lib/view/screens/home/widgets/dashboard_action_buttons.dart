// lib/view/screens/home/widgets/dashboard_action_buttons.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view/screens/appointments/request_appointment_screen.dart';

class DashboardActionButtons extends StatelessWidget {
  const DashboardActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: AppColors.primaryColor.withAlpha(102),
              elevation: 5,
            ),
          ),
        ),
        const SizedBox(height: 16),
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
              MaterialPageRoute(builder: (_) => const RequestAppointmentScreen()),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              backgroundColor: AppColors.accentColor,
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