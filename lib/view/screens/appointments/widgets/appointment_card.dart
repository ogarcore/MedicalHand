// lib/view/screens/appointments/widgets/appointment_card.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
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

  void _showConfirmationSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.successColor(context).withAlpha(220),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.only(bottom: 10, left: 20, right: 20),
        duration: Duration(seconds: 3),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _cancelAppointment() {
    final viewModel = Provider.of<AppointmentViewModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => CustomModal(
        title: 'Confirmar Cancelación',
        icon: HugeIcons.strokeRoundedCancelCircleHalfDot,
        content: const Text(
          '¿Estás seguro de que deseas cancelar esta cita?',
          textAlign: TextAlign.center,
        ),
        actions: [
          ModalButton(text: 'Volver', onPressed: () => Navigator.of(ctx).pop()),
          ModalButton(
            text: 'Sí, cancelar',
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
          title: 'Reprogramación',
          subtitle:
              'Tu cita volverá al estado "Pendiente" para que el hospital te asigne una nueva fecha.',
          icon: HugeIcons.strokeRoundedRepeat,
          content: Form(
            key: formKey,
            child: CustomTextField(
              labelText: "Motivo de la reprogramación",
              icon: HugeIcons.strokeRoundedAlertDiamond,
              controller: reasonController,
              hintText: 'Explica brevemente por qué necesitas el cambio...',
              maxLines: 3,
              validator: AppValidators.validateRescheduleReason,
            ),
          ),
          actions: [
            ModalButton(
              text: 'Cancelar',
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ModalButton(
              text: 'Aceptar',
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
        'd MMM, y - hh:mm a',
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor(context).withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header compacto
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    cita.specialty ?? 'Consulta Externa',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor(context),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(cita.status),
              ],
            ),

            const SizedBox(height: 10),

            // Línea divisoria más delgada
            Container(
              height: 2,
              width: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryColor(context).withAlpha(170),
                borderRadius: BorderRadius.circular(1),
              ),
            ),

            const SizedBox(height: 10),

            // Contenido compacto
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono más compacto
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryColor(context).withAlpha(150),
                        AppColors.primaryColor(context).withAlpha(170),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    HugeIcons.strokeRoundedHospital01,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),

                // Información compacta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hospital
                      Text(
                        cita.hospital,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor(context),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Fecha
                      _buildInfoRow(
                        HugeIcons.strokeRoundedCalendar01,
                        _formatDate(),
                      ),

                      // Doctor (solo para citas pasadas)
                      if (!widget.isUpcoming) ...[
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          HugeIcons.strokeRoundedDoctor01,
                          cita.assignedDoctor ?? 'Por Asignar',
                          maxLines: 1,
                        ),
                      ],

                      // Consultorio
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        HugeIcons.strokeRoundedHospitalBed01,
                        cita.clinicOffice ?? 'Por Asignar',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Sección de opciones (si aplica)
            if (showOptions) _buildOptionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {int maxLines = 2}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primaryColor(context)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Opciones",
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
                    top: 10.0,
                    right: 12,
                    left: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _rescheduleAppointment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentColor(
                              context,
                            ).withAlpha(170),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 1,
                            shadowColor: AppColors.accentColor(
                              context,
                            ).withAlpha(100),
                          ),
                          child: const Text(
                            "Reprogramar",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
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
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: AppColors.warningColor(context),
                                width: 1.2,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Cancelar",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
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
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData? icon;

    final displayStatus = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ')
        : '';

    switch (status) {
      case 'confirmada':
        backgroundColor = AppColors.secondaryColor(context).withAlpha(40);
        textColor = AppColors.primaryColor(context);
        icon = HugeIcons.strokeRoundedTickDouble01;
        break;
      case 'pendiente':
        backgroundColor = AppColors.graceColor(context).withAlpha(40);
        textColor = AppColors.graceColor(context);
        icon = HugeIcons.strokeRoundedClock01;
        break;
      case 'finalizada':
        backgroundColor = AppColors.textLightColor(context).withAlpha(40);
        textColor = AppColors.textLightColor(context);
        icon = HugeIcons.strokeRoundedCheckmarkSquare03;
        break;
      case 'cancelada':
        backgroundColor = AppColors.warningColor(context).withAlpha(40);
        textColor = AppColors.warningColor(context);
        icon = HugeIcons.strokeRoundedCancelCircleHalfDot;
        break;
      case 'pendiente_reprogramacion':
        backgroundColor = AppColors.accentColor(context).withAlpha(40);
        textColor = AppColors.accentColor(context);
        icon = HugeIcons.strokeRoundedRepeat;
        break;
      default:
        backgroundColor = Colors.grey.withAlpha(50);
        textColor = Colors.grey.shade800;
        icon = HugeIcons.strokeRoundedHelpSquare;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 3),
          Text(
            displayStatus,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
