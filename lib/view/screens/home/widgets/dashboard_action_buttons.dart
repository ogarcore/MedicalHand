import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view/screens/appointments/appointment_options_screen.dart';

class DashboardActionButtons extends StatelessWidget {
  final bool canCheckIn;

  const DashboardActionButtons({super.key, required this.canCheckIn});

  @override
  Widget build(BuildContext context) {
    final warniniColor = AppColors.warningColor(context);
    final accentColor = AppColors.accentColor(context);

    return Column(
      children: [
        if (canCheckIn)
          _buildCompactGlamorousButton(
            context: context,
            title: 'Confirmar asistencia',
            subtitle: 'Recibir turno',
            icon: HugeIcons.strokeRoundedTickDouble04,
            primaryColor: warniniColor,
            onPressed: () {
              // Lógica para el check-in
            },
          ),
        if (canCheckIn) const SizedBox(height: 12),
        _buildCompactGlamorousButton(
          context: context,
          title: 'Agendar cita',
          subtitle: 'Nueva consulta',
          icon: HugeIcons.strokeRoundedLayerAdd,
          primaryColor: accentColor,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AppointmentOptionsScreen(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactGlamorousButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color primaryColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 68, // Más compacto
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            primaryColor,
            Color.lerp(primaryColor.withAlpha(190), Colors.black, 0.08)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withAlpha(70),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.white.withAlpha(40),
          highlightColor: Colors.white.withAlpha(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withAlpha(50),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                // Icono más compacto
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withAlpha(70),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                
                // Texto más compacto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withAlpha(220),
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Flecha más compacta
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(70),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    HugeIcons.strokeRoundedArrowRight01,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}