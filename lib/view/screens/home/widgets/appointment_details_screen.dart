import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/cita_model.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final CitaModel appointment;

  const AppointmentDetailsScreen({super.key, required this.appointment});

  String _formatFullDate(DateTime? date) {
    if (date == null) return 'Fecha no asignada';
    String formatted = DateFormat(
      'EEEE, d \'de\' MMMM \'de\' y',
      'es_ES',
    ).format(date);
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  String _formatTime(DateTime? date) {
    if (date == null) return 'Hora no asignada';
    return DateFormat('hh:mm a', 'es_ES').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: const Text(
          'Detalles de la Cita',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withAlpha(15),
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.textColor(context)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildDetailsCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, Color.lerp(primaryColor, Colors.black, 0.1)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono compacto
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(60), width: 1.5),
            ),
            child: Icon(
              HugeIcons.strokeRoundedHealth,
              size: 24,
              color: Colors.white.withAlpha(230),
            ),
          ),
          const SizedBox(width: 16),
          
          // Contenido textual compacto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.specialty ?? 'Consulta Externa',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cita médica programada',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(200),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);

    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header compacto de la card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade100, width: 1.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: primaryColor.withAlpha(40),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    HugeIcons.strokeRoundedCheckList,
                    size: 16,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Información de la Cita',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),

          // Contenido de detalles compacto
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDetailItem(
                  context: context,
                  icon: HugeIcons.strokeRoundedHospital01,
                  title: 'Hospital',
                  subtitle: appointment.hospital,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(height: 16),
                _buildDetailItem(
                  context: context,
                  icon: HugeIcons.strokeRoundedCalendar02,
                  title: 'Fecha',
                  subtitle: _formatFullDate(appointment.assignedDate),
                  color: Colors.green.shade600,
                ),
                const SizedBox(height: 16),
                _buildDetailItem(
                  context: context,
                  icon: HugeIcons.strokeRoundedClock01,
                  title: 'Hora',
                  subtitle: _formatTime(appointment.assignedDate),
                  color: Colors.orange.shade600,
                ),
                const SizedBox(height: 16),
                _buildDetailItem(
                  context: context,
                  icon: HugeIcons.strokeRoundedHospitalBed01,
                  title: 'Consultorio',
                  subtitle: appointment.clinicOffice ?? 'No asignado',
                  color: Colors.purple.shade600,
                ),
                const SizedBox(height: 16),
                _buildDetailItem(
                  context: context,
                  icon: HugeIcons.strokeRoundedNote01,
                  title: 'Razón',
                  subtitle: appointment.reason,
                  color: Colors.red.shade600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icono compacto
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withAlpha(40), width: 1.5),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),

        // Contenido textual compacto
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  height: 1.3,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}