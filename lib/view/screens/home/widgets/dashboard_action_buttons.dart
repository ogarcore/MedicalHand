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
        if (canCheckIn)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(HugeIcons.strokeRoundedTickDouble04, size: 20),
              label: const Text(
                'Confirmar asistencia y recibir turno',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                // Lógica para el check-in
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primaryColor(context),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                shadowColor: Colors.black.withAlpha(130),
                elevation: 3,
              ),
            ),
          ),
        if (canCheckIn) const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(
              HugeIcons.strokeRoundedLayerAdd,
              size: 20,
              color: Colors.white,
            ),
            label: const Text(
              'Agendar Nueva Cita',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AppointmentOptionsScreen(),
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.accentColor(context),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              shadowColor: Colors.black.withOpacity(0.15),
              elevation: 3,
            ),
          ),
        ),
      ],
    );
  }
}
