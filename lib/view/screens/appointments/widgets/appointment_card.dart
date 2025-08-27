// lib/view/screens/appointments/widgets/appointment_card.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class AppointmentCard extends StatelessWidget {
  final bool isUpcoming;
  final String specialty;
  final String hospital;
  final String date;
  final String status;
  final String doctor;
  final String office;

  const AppointmentCard({
    super.key,
    required this.isUpcoming,
    required this.specialty,
    required this.hospital,
    required this.date,
    required this.status,
    required this.doctor,
    required this.office,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(160),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      // ----- INICIO DEL CAMBIO -----
      // Usamos un Stack para posicionar el botón de cancelar encima del contenido.
      child: Stack(
        children: [
          // Tu contenido original va aquí, sin cambios.
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      // Dejamos un poco de espacio a la derecha para que el texto no choque con el botón.
                      child: Padding(
                        padding: const EdgeInsets.only(right: 32.0),
                        child: Text(
                          specialty,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    _buildStatusChip(status),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 3,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withAlpha(170),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryColor.withAlpha(150),
                            AppColors.primaryColor.withAlpha(170),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        HugeIcons.strokeRoundedHospital01,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hospital,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                HugeIcons.strokeRoundedCalendar01,
                                size: 14,
                                color: AppColors.primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  date,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!isUpcoming) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  HugeIcons.strokeRoundedDoctor01,
                                  size: 14,
                                  color: AppColors.primaryColor,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    doctor,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                HugeIcons.strokeRoundedLocation01,
                                size: 14,
                                color: AppColors.primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  office,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Este es el botón de cancelar, posicionado encima del contenido.
          if (isUpcoming)
            Positioned(
              bottom: 4,
              right: 4,
              child: IconButton(
                onPressed: () {
                  // Aquí puedes mostrar un diálogo de confirmación antes de cancelar.
                  print('Botón "Cancelar Cita" presionado para: $specialty');
                },
                icon: const Icon(HugeIcons.strokeRoundedDelete02),
                color: AppColors.warningColor.withAlpha(200),
                iconSize: 22,
              ),
            ),
        ],
      ),
      // ----- FIN DEL CAMBIO -----
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData? icon;

    switch (status) {
      case 'Confirmada':
        backgroundColor = AppColors.secondaryColor.withAlpha(40);
        textColor = AppColors.primaryColor;
        icon = HugeIcons.strokeRoundedTickDouble01;
        break;
      case 'Pendiente':
        backgroundColor = AppColors.graceColor.withAlpha(40);
        textColor = AppColors.graceColor;
        icon = HugeIcons.strokeRoundedClock01;
        break;
      case 'Finalizada':
        backgroundColor = AppColors.textLightColor.withAlpha(40);
        textColor = AppColors.textLightColor;
        icon = HugeIcons.strokeRoundedCheckmarkSquare03;
        break;
      case 'Cancelada':
        backgroundColor = AppColors.warningColor.withAlpha(40);
        textColor = AppColors.warningColor;
        icon = HugeIcons.strokeRoundedCancelCircleHalfDot;
        break;
      default:
        backgroundColor = Colors.grey.withAlpha(50);
        textColor = Colors.grey.shade800;
        icon = HugeIcons.strokeRoundedHelpSquare;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}