// lib/view/screens/home/widgets/next_appointment_card.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/cita_model.dart';

class NextAppointmentCard extends StatelessWidget {
  final CitaModel appointment;

  const NextAppointmentCard({super.key, required this.appointment});

  // CAMBIO: La lógica de formato ahora usa el objeto 'appointment'
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
        color: Colors.white.withAlpha(160),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(38),
            spreadRadius: 1,
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
            padding: const EdgeInsets.all(20),
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
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  HugeIcons.strokeRoundedCalendar03,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(width: 10),
                Text(
                  'Tu Próxima Cita',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Contenido de la cita
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CAMBIO: Los datos ahora son dinámicos
                _buildInfoRow(
                  HugeIcons.strokeRoundedMicroscope,
                  'Especialidad',
                  appointment.specialty ?? 'Consulta General',
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  HugeIcons.strokeRoundedHospital01,
                  'Hospital',
                  appointment.hospital,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  HugeIcons.strokeRoundedHospitalBed01,
                  'Consultorio',
                  appointment.clinicOffice ?? 'Por Asignar',
                ),
                const SizedBox(height: 16),
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
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