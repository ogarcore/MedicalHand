// lib/view/widgets/appointment/reschedule_appointment_content.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/data/models/cita_model.dart';
import 'package:p_hn25/view/widgets/custom_modal.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
import 'package:p_hn25/view_model/appointment_view_model.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';

class RescheduleAppointmentContent extends StatefulWidget {
  final CitaModel appointment;
  final Function(String) onSubmitted;

  const RescheduleAppointmentContent({
    super.key,
    required this.appointment,
    required this.onSubmitted,
  });

  @override
  State<RescheduleAppointmentContent> createState() =>
      _RescheduleAppointmentContentState();
}

class _RescheduleAppointmentContentState
    extends State<RescheduleAppointmentContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final viewModel =
          Provider.of<AppointmentViewModel>(context, listen: false);
      final reason = _reasonController.text.trim();

      viewModel.requestReschedule(
        appointmentId: widget.appointment.id!,
        reason: reason,
        previousDate: widget.appointment.assignedDate!,
      );

      // Cierra el modal y llama al callback para mostrar la confirmación.
      Navigator.of(context).pop();
      widget.onSubmitted('Solicitud de reprogramación enviada.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomModal(
      title: 'reprogramacin'.tr(),
      subtitle:
          'Tu cita volverá al estado "Pendiente" para que el hospital te asigne una nueva fecha.',
      icon: HugeIcons.strokeRoundedRepeat,
      content: Form(
        key: _formKey,
        child: CustomTextField(
          labelText: 'motivo_de_la_reprogramacin'.tr(),
          icon: HugeIcons.strokeRoundedAlertDiamond,
          controller: _reasonController,
          hintText: 'explica_brevemente_por_qu_necesitas_el_cambio'.tr(),
          maxLines: 3,
          validator: AppValidators.validateRescheduleReason,
        ),
      ),
      actions: [
        ModalButton(
          text: 'cancelar'.tr(),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ModalButton(
          text: 'aceptar'.tr(),
          onPressed: _submit,
          isPrimary: true,
        ),
      ],
    );
  }
}