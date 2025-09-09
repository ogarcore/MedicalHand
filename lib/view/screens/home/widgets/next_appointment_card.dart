// lib/view/screens/home/widgets/next_appointment_card.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/cita_model.dart';

class NextAppointmentCard extends StatelessWidget {
  final CitaModel appointment;

  const NextAppointmentCard({super.key, required this.appointment});

  // La lógica de formato ahora usa el objeto 'appointment'
  String _formatFullDate() {
    if (appointment.assignedDate == null) return 'Fecha no asignada';
    return "${DateFormat('d MMMM', 'es_ES').format(appointment.assignedDate!)} - ${DateFormat('hh:mm a', 'es_ES').format(appointment.assignedDate!)}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con gradiente
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withAlpha(204),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  HugeIcons.strokeRoundedCalendar03,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Tu Próxima Cita',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          // Contenido de la cita
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Los datos ahora son dinámicos
                _buildInfoRow(
                  HugeIcons.strokeRoundedMicroscope,
                  'Especialidad',
                  appointment.specialty ?? 'Consulta General',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  HugeIcons.strokeRoundedHospital01,
                  'Hospital',
                  appointment.hospital,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  HugeIcons.strokeRoundedHospitalBed01,
                  'Consultorio',
                  appointment.clinicOffice ?? 'Por Asignar',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  HugeIcons.strokeRoundedDateTime,
                  'Fecha y Hora',
                  _formatFullDate(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fila de información
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
