import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/cita_model.dart';
import 'package:p_hn25/view/screens/home/widgets/appointment_details_modal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class NextAppointmentCard extends StatelessWidget {
  final CitaModel appointment;

  const NextAppointmentCard({super.key, required this.appointment});

  // Nueva función para lanzar los mapas, ahora usando GeoPoint
  Future<void> _launchMaps(BuildContext context, GeoPoint? hospitalLocation) async {
    // 1. Validar que la ubicación no sea nula
    
    if (hospitalLocation == null) {
      _showErrorSnackBar(context, 'La ubicación del hospital no está disponible.');
      return;
    }

    // 2. Extraer latitud y longitud del GeoPoint
    final lat = hospitalLocation.latitude;
    final lon = hospitalLocation.longitude;

    // 3. Construir la URL universal de Google Maps
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lon');

    // 4. Intentar abrir la URL en una aplicación externa
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
    
      // ignore: use_build_context_synchronously
      _showErrorSnackBar(context, 'No se pudo abrir la aplicación de mapas.');
    }
  }

  // Widget auxiliar para mostrar mensajes de error
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime() {
    if (appointment.assignedDate == null) return '--:--';
    return DateFormat('hh:mm a', 'es_ES').format(appointment.assignedDate!);
  }

  String _formatDay() {
    if (appointment.assignedDate == null) return '--';
    return DateFormat('d', 'es_ES').format(appointment.assignedDate!);
  }

  String _formatMonth() {
    if (appointment.assignedDate == null) return '---';
    return DateFormat('MMM', 'es_ES').format(appointment.assignedDate!);
  }

  String _formatWeekday() {
    if (appointment.assignedDate == null) return '---';
    final now = DateTime.now();
    final assigned = appointment.assignedDate!;
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate = DateTime(assigned.year, assigned.month, assigned.day);

    if (appointmentDate == today) {
      return 'Hoy';
    } else if (appointmentDate == today.add(const Duration(days: 1))) {
      return 'Mañana';
    } else {
      String weekday = DateFormat('EEEE', 'es_ES').format(appointmentDate);
      return weekday[0].toUpperCase() + weekday.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  Color.lerp(primaryColor.withAlpha(225), Colors.black, 0.1)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'prxima_cita'.tr(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            HugeIcons.strokeRoundedCalendar02,
                            size: 16,
                            color: Colors.white.withAlpha(200),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatWeekday(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            HugeIcons.strokeRoundedClock01,
                            size: 16,
                            color: Colors.white.withAlpha(200),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withAlpha(220),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withAlpha(60),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatDay(),
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        _formatMonth().toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withAlpha(220),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Ver Detalles',
                    HugeIcons.strokeRoundedEye,
                    primaryColor,
                    hasBorder: true,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AppointmentDetailsModal(
                          appointment: appointment,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Cómo Llegar',
                    HugeIcons.strokeRoundedMaps,
                    primaryColor,
                    isPrimary: true,
                    // CAMBIO CLAVE: Llamamos a la función _launchMaps con el campo GeoPoint.
                    onPressed: () => _launchMaps(context, appointment.hospitalLocation),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color, {
    bool isPrimary = false,
    bool hasBorder = false,
    VoidCallback? onPressed,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: isPrimary
            ? LinearGradient(
                colors: [color, Color.lerp(color, Colors.black, 0.1)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: color.withAlpha(80),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
        border: hasBorder
            ? Border.all(color: color.withAlpha(100), width: 1.5)
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.transparent : Colors.white,
          foregroundColor: isPrimary ? Colors.white : color,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isPrimary ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isPrimary ? Colors.white : color,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}