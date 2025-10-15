import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/view/widgets/custom_modal.dart';
import 'package:p_hn25/data/models/cita_model.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
import 'package:p_hn25/view_model/appointment_view_model.dart';
import 'package:provider/provider.dart';

class AppointmentCard extends StatefulWidget {
  final CitaModel appointment;
  final bool isUpcoming;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.isUpcoming,
  });

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  bool _isExpanded = false;

  // --- INICIO DE LA MODIFICACIÓN ---
  // Nueva función para mostrar el diálogo de detalles.
  void _showDetailsDialog() {
    final cita = widget.appointment;
    showDialog(
      context: context,
      builder: (ctx) => CustomModal(
        title: 'detalles_de_la_cita'.tr(),
        icon: HugeIcons.strokeRoundedDocumentValidation,
        content: SingleChildScrollView(
          // Para asegurar que no haya overflow si el texto es largo
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                HugeIcons.strokeRoundedStethoscope,
                'Especialidad',
                cita.specialty ?? 'No especificada',
              ),
              _buildDetailRow(
                HugeIcons.strokeRoundedCalendar01,
                'Fecha y Hora',
                _formatDate(),
              ),
              _buildDetailRow(
                HugeIcons.strokeRoundedHospital01,
                'Hospital',
                cita.hospital,
              ),
              _buildDetailRow(
                HugeIcons.strokeRoundedDoctor01,
                'Doctor',
                cita.assignedDoctor ?? 'No asignado',
              ),
              _buildDetailRow(
                HugeIcons.strokeRoundedHospitalBed01,
                'Consultorio',
                cita.clinicOffice ?? 'No asignado',
              ),
              _buildDetailRow(
                HugeIcons.strokeRoundedTask01,
                'Razón de Consulta',
                cita.reason,
              ),
            ],
          ),
        ),
        actions: [
          ModalButton(
            text: 'cerrar'.tr(),
            onPressed: () => Navigator.of(ctx).pop(),
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  // Nuevo widget auxiliar para crear las filas de detalles en el diálogo.
  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryColor(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // --- FIN DE LA MODIFICACIÓN ---

  void _showConfirmationSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.successColor(context).withAlpha(220),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
        duration: const Duration(seconds: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _cancelAppointment() {
    final viewModel = Provider.of<AppointmentViewModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => CustomModal(
        title: 'confirmar_cancelacin'.tr(),
        icon: HugeIcons.strokeRoundedCancelCircleHalfDot,
        content: Text(
          '¿Estás seguro de que deseas cancelar esta cita?',
          textAlign: TextAlign.center,
        ),
        actions: [
          ModalButton(
            text: 'volver'.tr(),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ModalButton(
            text: 's_cancelar'.tr(),
            onPressed: () {
              Navigator.of(ctx).pop();
              viewModel.updateAppointmentStatus(
                widget.appointment.id!,
                'cancelada',
              );
              _showConfirmationSnackBar('Cita cancelada exitosamente.');
            },
            isWarning: true,
          ),
        ],
      ),
    );
  }

  void _rescheduleAppointment() {
    final viewModel = Provider.of<AppointmentViewModel>(context, listen: false);
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return CustomModal(
          title: 'reprogramacin'.tr(),
          subtitle:
              'Tu cita volverá al estado "Pendiente" para que el hospital te asigne una nueva fecha.',
          icon: HugeIcons.strokeRoundedRepeat,
          content: Form(
            key: formKey,
            child: CustomTextField(
              labelText: 'motivo_de_la_reprogramacin'.tr(),
              icon: HugeIcons.strokeRoundedAlertDiamond,
              controller: reasonController,
              hintText: 'explica_brevemente_por_qu_necesitas_el_cambio'.tr(),
              maxLines: 3,
              validator: AppValidators.validateRescheduleReason,
            ),
          ),
          actions: [
            ModalButton(
              text: 'cancelar'.tr(),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ModalButton(
              text: 'aceptar'.tr(),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(ctx).pop();
                  viewModel.requestReschedule(
                    appointmentId: widget.appointment.id!,
                    reason: reasonController.text.trim(),
                    previousDate: widget.appointment.assignedDate!,
                  );
                  _showConfirmationSnackBar(
                    'Solicitud de reprogramación enviada.',
                  );
                }
              },
              isPrimary: true,
            ),
          ],
        );
      },
    );
  }

  String _formatDate() {
    if (widget.appointment.status == 'pendiente' ||
        widget.appointment.status == 'pendiente_reprogramacion') {
      return 'Por asignar';
    }
    if (widget.appointment.assignedDate != null) {
      return DateFormat(
        widget.isUpcoming ? 'd MMM, y - hh:mm a' : 'd MMMM \'de\' y',
        'es_ES',
      ).format(widget.appointment.assignedDate!);
    }
    return 'Fecha no disponible';
  }

  @override
  Widget build(BuildContext context) {
    final bool showOptions =
        widget.isUpcoming && widget.appointment.status == 'confirmada';
    final cita = widget.appointment;

    List<Color> headerGradientColors;
    switch (cita.status) {
      case 'no_asistio':
        final primaryColor = AppColors.textLightColor(context).withAlpha(220);
        headerGradientColors = [
          primaryColor,
          Color.lerp(
            primaryColor.withAlpha(210),
            const Color.fromARGB(255, 88, 88, 88),
            0.3,
          )!,
        ];
        break;
      case 'confirmada':
        final primaryColor = AppColors.primaryColor(context);
        headerGradientColors = [
          primaryColor,
          Color.lerp(primaryColor, Colors.blue.shade700, 0.3)!,
        ];
      case 'asistencia_confirmada':
        final primaryColor = AppColors.primaryColor(context);
        headerGradientColors = [
          primaryColor,
          Color.lerp(primaryColor, Colors.blue.shade700, 0.3)!,
        ];
        break;
      case 'cancelada':
        final warningColor = AppColors.warningColor(context);
        headerGradientColors = [
          warningColor.withAlpha(230),
          Color.lerp(warningColor.withAlpha(220), Colors.black, 0.1)!,
        ];
        break;
      case 'pendiente':
        final graceColor = AppColors.graceColor(context);
        headerGradientColors = [
          Color.lerp(graceColor.withAlpha(180), Colors.black, 0.08)!,
          graceColor.withAlpha(200),
          Color.lerp(graceColor.withAlpha(180), Colors.brown, 0.2)!,
        ];
        break;
      case 'finalizada':
        final secondaryColor = AppColors.secondaryColor(context);
        headerGradientColors = [
          secondaryColor.withAlpha(200),
          Color.lerp(
            AppColors.primaryColor(context).withAlpha(200),
            Colors.black,
            0.15,
          )!,
        ];
        break;
      case 'pendiente_reprogramacion':
        final accentColor = AppColors.accentColor(context);
        headerGradientColors = [
          accentColor,
          Color.lerp(accentColor, Colors.indigo.shade900, 0.3)!,
        ];
        break;
      default:
        headerGradientColors = [Colors.grey.shade800, Colors.black];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: headerGradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withAlpha(40),
                        Colors.white.withAlpha(20),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withAlpha(60),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    HugeIcons.strokeRoundedHospital01,
                    color: Colors.white.withAlpha(220),
                    size: 16.5,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cita.specialty ?? 'consulta_externa'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withAlpha(240),
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(cita.status),
              ],
            ),
          ),

          // --- CAMBIO: Padding más compacto solo para cards finalizadas ---
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              10,
              20,
              cita.status == 'finalizada'
                  ? 12
                  : 16, // Reducido bottom padding para finalizadas
            ),
            child: widget.isUpcoming
                ? _buildUpcomingContent(cita)
                : _buildPastContent(cita),
          ),

          if (showOptions) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.shade100,
                      Colors.grey.shade300,
                      Colors.grey.shade100,
                    ],
                  ),
                ),
              ),
            ),
            _buildOptionsSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildUpcomingContent(CitaModel cita) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cita.hospital,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textColor(context),
            letterSpacing: -0.2,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        _buildInfoRow(HugeIcons.strokeRoundedCalendar01, _formatDate()),
        const SizedBox(height: 6),
        _buildInfoRow(
          HugeIcons.strokeRoundedHospitalBed01,
          cita.clinicOffice ?? 'Por Asignar',
        ),
      ],
    );
  }

  Widget _buildPastContent(CitaModel cita) {
    switch (cita.status) {
      case 'no_asistio':
        return _buildContent(cita);
      case 'cancelada':
        return _buildContent(cita);
      case 'finalizada':
        return _buildFinalizadaContent(cita);
      default:
        return _buildContent(cita);
    }
  }

  Widget _buildContent(CitaModel cita) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cita.hospital,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textColor(context),
            letterSpacing: -0.2,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        _buildInfoRow(HugeIcons.strokeRoundedCalendar01, _formatDate()),
      ],
    );
  }

  Widget _buildFinalizadaContent(CitaModel cita) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cita.hospital,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textColor(context),
            letterSpacing: -0.2,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        // --- CAMBIOS: Espacios reducidos para hacerla más compacta ---
        const SizedBox(height: 6), // Reducido de 10 a 8
        _buildInfoRow(HugeIcons.strokeRoundedCalendar01, _formatDate()),
        const SizedBox(height: 6), // Reducido espacio antes del botón
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _showDetailsDialog,
            // Ícono más pequeño
            label: Text(
              'ver_detalles'.tr(),
              style: TextStyle(
                fontWeight: FontWeight.w700, // Cambiado a w600 en lugar de bold
                fontSize: 13.5, // Texto más pequeño
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryColor(context),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ), // Padding más compacto
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  10,
                ), // Border radius más pequeño
              ),
              minimumSize: Size.zero, // Elimina tamaño mínimo
              tapTargetSize: MaterialTapTargetSize
                  .shrinkWrap, // Hace el área táctil más compacta
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {int maxLines = 2}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primaryColor(context)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLightColor(context),
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'opciones_de_la_cita'.tr(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentColor(context).withAlpha(220),
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: _isExpanded ? 0.5 : 0,
                        child: Icon(
                          HugeIcons.strokeRoundedArrowDownDouble,
                          size: 16,
                          color: AppColors.accentColor(context).withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Column(
              children: [
                if (_isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 8,
                      left: 4,
                      right: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _rescheduleAppointment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentColor(
                                context,
                              ).withAlpha(200),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 1,
                              shadowColor: AppColors.accentColor(
                                context,
                              ).withAlpha(100),
                            ),
                            child: Text(
                              'reprogramar'.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _cancelAppointment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withAlpha(20),
                              foregroundColor: AppColors.warningColor(context),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: AppColors.warningColor(context),
                                  width: 1.5,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'cancelar'.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
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
    );
  }

  Widget _buildStatusChip(String status) {
    const Color chipTextColor = Colors.white;
    final Color chipBackgroundColor = Colors.white.withAlpha(40);
    IconData? icon;

    final displayStatus = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ')
        : '';

    switch (status) {
      case 'no_asistio':
        icon = HugeIcons.strokeRoundedCalendarRemove02;
        break;
      case 'confirmada':
        icon = HugeIcons.strokeRoundedTickDouble01;
        break;
      case 'pendiente':
        icon = HugeIcons.strokeRoundedClock01;
        break;
      case 'finalizada':
        icon = HugeIcons.strokeRoundedCheckmarkSquare03;
        break;
      case 'cancelada':
        icon = HugeIcons.strokeRoundedCancelCircleHalfDot;
        break;
      case 'pendiente_reprogramacion':
        icon = HugeIcons.strokeRoundedRepeat;
        break;
      default:
        icon = HugeIcons.strokeRoundedHelpSquare;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(80), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: chipTextColor),
          const SizedBox(width: 4),
          Text(
            displayStatus,
            style: const TextStyle(
              color: chipTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
