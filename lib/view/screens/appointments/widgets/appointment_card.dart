// lib/view/screens/appointments/widgets/appointment_card.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/view/widgets/custom_modal.dart';
import 'package:p_hn25/data/models/cita_model.dart';
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

  void _cancelAppointment() {
    final viewModel = Provider.of<AppointmentViewModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => CustomModal(
        title: 'Confirmar Cancelación',
        icon: HugeIcons.strokeRoundedCancelCircleHalfDot,
        content: Text(
          '¿Estás seguro de que deseas cancelar esta cita?',
          textAlign: TextAlign.center,
        ),
        actions: [
          ModalButton(
            text: 'Cancelar',
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ModalButton(
            text: 'Aceptar',
            onPressed: () {
              Navigator.of(ctx).pop();
              viewModel.updateAppointmentStatus(
                widget.appointment.id!,
                'cancelada',
              );
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
            child: TextFormField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo de la reprogramación',
                hintText: 'Explica brevemente por qué necesitas el cambio...',
                border: OutlineInputBorder(),
              ),
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
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 32.0),
                    child: Text(
                      cita.specialty ?? 'Consulta General',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                _buildStatusChip(cita.status),
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
                        cita.hospital,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                        maxLines: 2,
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
                              _formatDate(),
                              style: TextStyle(
                                fontSize: 13.5,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!widget.isUpcoming) ...[
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
                                cita.assignedDoctor ?? 'Por Asignar',
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
                              cita.clinicOffice ?? 'Por Asignar',
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
            if (showOptions) _buildOptionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
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
                      "Opciones",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentColor.withAlpha(220),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: _isExpanded ? 0.5 : 0,
                      child: Icon(
                        HugeIcons.strokeRoundedArrowDownDouble,
                        size: 18,
                        color: AppColors.accentColor.withAlpha(200),
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
                    top: 12.0,
                    right: 15,
                    left: 15,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _rescheduleAppointment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentColor.withAlpha(
                              170,
                            ),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 1,
                            shadowColor: AppColors.accentColor.withAlpha(100),
                          ),
                          child: const Text(
                            "Reprogramar",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _cancelAppointment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withAlpha(20),
                            foregroundColor: AppColors.warningColor,
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: AppColors.warningColor,
                                width: 1.2,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Cancelar cita",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
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
        backgroundColor = AppColors.secondaryColor.withAlpha(40);
        textColor = AppColors.primaryColor;
        icon = HugeIcons.strokeRoundedTickDouble01;
        break;
      case 'pendiente':
        backgroundColor = AppColors.graceColor.withAlpha(40);
        textColor = AppColors.graceColor;
        icon = HugeIcons.strokeRoundedClock01;
        break;
      case 'finalizada':
        backgroundColor = AppColors.textLightColor.withAlpha(40);
        textColor = AppColors.textLightColor;
        icon = HugeIcons.strokeRoundedCheckmarkSquare03;
        break;
      case 'cancelada':
        backgroundColor = AppColors.warningColor.withAlpha(40);
        textColor = AppColors.warningColor;
        icon = HugeIcons.strokeRoundedCancelCircleHalfDot;
        break;
      case 'pendiente_reprogramacion':
        backgroundColor = AppColors.accentColor.withAlpha(40);
        textColor = AppColors.accentColor;
        icon = HugeIcons.strokeRoundedRepeat;
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
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            displayStatus,
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
