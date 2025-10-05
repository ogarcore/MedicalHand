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

  // --- NINGÚN CAMBIO EN LA LÓGICA ---
  // Todas las funciones de aquí abajo permanecen intactas.

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
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

    // --- NUEVO: Lógica para el color dinámico del Header ---
    List<Color> headerGradientColors;

    switch (cita.status) {
      case 'confirmada':
        final primaryColor = AppColors.primaryColor(context);
        headerGradientColors = [
          primaryColor,
          Color.lerp(primaryColor, Colors.blue.shade700, 0.3)!,
        ];
        break;
      case 'cancelada':
        final warningColor = AppColors.warningColor(context);
        headerGradientColors = [
          warningColor.withAlpha(220),
          Color.lerp(warningColor, Colors.black, 0.1)!,
        ];
        break;
      case 'pendiente':
        final graceColor = AppColors.graceColor(context);
        headerGradientColors = [
          graceColor.withAlpha(210),
          Color.lerp(graceColor.withAlpha(170), Colors.brown, 0.3)!,
        ];
        break;
      case 'finalizada':
        headerGradientColors = [
          Colors.grey.shade700,
          Colors.grey.shade900,
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
        headerGradientColors = [
          Colors.grey.shade800,
          Colors.black,
        ];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          // Header con el nuevo color dinámico
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: headerGradientColors, // <-- Color dinámico aplicado aquí
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
                        cita.specialty ?? 'Consulta Externa',
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

          // Contenido de la Cita (sin cambios)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
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
                      _buildInfoRow(
                        HugeIcons.strokeRoundedCalendar01,
                        _formatDate(),
                      ),
                      if (!widget.isUpcoming) ...[
                        const SizedBox(height: 6),
                        _buildInfoRow(
                          HugeIcons.strokeRoundedDoctor01,
                          cita.assignedDoctor ?? 'Por Asignar',
                          maxLines: 1,
                        ),
                      ],
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        HugeIcons.strokeRoundedHospitalBed01,
                        cita.clinicOffice ?? 'Por Asignar',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sección de Opciones (sin cambios)
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
          ]
        ],
      ),
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
              fontSize: 13,
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
                        "Opciones de la cita",
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
                    padding:
                        const EdgeInsets.only(top: 8.0, bottom: 8, left: 4, right: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _rescheduleAppointment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentColor(context)
                                  .withAlpha(200),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 1,
                              shadowColor: AppColors.accentColor(context)
                                  .withAlpha(100),
                            ),
                            child: const Text(
                              "Reprogramar",
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: AppColors.warningColor(context),
                                  width: 1.5,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Cancelar",
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

  // --- WIDGET AUXILIAR MODIFICADO ---
  Widget _buildStatusChip(String status) {
    // --- NUEVO: Variables de color constantes para el chip ---
    const Color chipTextColor = Colors.white;
    final Color chipBackgroundColor = Colors.white.withAlpha(40);
    IconData? icon;

    final displayStatus = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ')
        : '';

    // El switch ahora solo define el ícono
    switch (status) {
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
        color: chipBackgroundColor, // <-- Color de fondo constante
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(80), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: chipTextColor), // <-- Color de ícono constante
          const SizedBox(width: 4),
          Text(
            displayStatus,
            style: const TextStyle(
              color: chipTextColor, // <-- Color de texto constante
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}