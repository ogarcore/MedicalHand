import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/cita_model.dart';

class AppointmentDetailsModal extends StatelessWidget {
  final CitaModel appointment;

  const AppointmentDetailsModal({super.key, required this.appointment});

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
    final primaryColor = AppColors.primaryColor(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75, // Reducido un poco
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Contenido principal
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundColor(context),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header con gradiente
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          Color.lerp(primaryColor, Colors.black, 0.15)!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withAlpha(60),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            HugeIcons.strokeRoundedCaduceus,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.specialty ?? 'consulta_externa'.tr(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'detalles_de_tu_cita_mdica'.tr(),
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.white.withAlpha(200),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contenido desplazable - CAMBIO PRINCIPAL
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tarjeta de información principal
                          _buildMainInfoCard(context),
                          const SizedBox(height: 16),
                          // Tarjeta de detalles adicionales
                          _buildDetailsCard(context),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Botón de cerrar
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(80),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, size: 16, color: Colors.white),
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfoCard(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header de la tarjeta
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor(context).withAlpha(230),
                    AppColors.accentColor(context).withAlpha(180),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: primaryColor.withAlpha(20),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: Colors.white.withAlpha(70),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      HugeIcons.strokeRoundedCalendar02,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'fecha_y_hora'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),

            // Contenido de fecha y hora - CORREGIDO LA ALINEACIÓN
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Cambiado a start
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'fecha'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatFullDate(appointment.assignedDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1, 
                    height: 40, 
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(horizontal: 18), // Mejor margen
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'hora'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatTime(appointment.assignedDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);
    final colorScheme = [
      primaryColor,
      AppColors.accentColor(context).withAlpha(180),
      AppColors.secondaryColor(context).withAlpha(180),
      AppColors.graceColor(context).withAlpha(180),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header de detalles
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor(context).withAlpha(230),
                    AppColors.accentColor(context).withAlpha(180),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: primaryColor.withAlpha(20),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: Colors.white.withAlpha(70),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      HugeIcons.strokeRoundedCheckList,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'informacin_adicional'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de detalles
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailItem(
                    context: context,
                    icon: HugeIcons.strokeRoundedHospital01,
                    title: 'hospital'.tr(),
                    subtitle: appointment.hospital,
                    color: colorScheme[1],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    context: context,
                    icon: HugeIcons.strokeRoundedHospitalBed01,
                    title: 'consultorio'.tr(),
                    subtitle: appointment.clinicOffice ?? 'No asignado',
                    color: colorScheme[2],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    context: context,
                    icon: HugeIcons.strokeRoundedNote01,
                    title: 'razn_de_la_consulta'.tr(),
                    subtitle: appointment.reason,
                    color: colorScheme[3],
                  ),
                ],
              ),
            ),
          ],
        ),
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
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: color.withAlpha(30), width: 1.5),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 14),
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
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
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