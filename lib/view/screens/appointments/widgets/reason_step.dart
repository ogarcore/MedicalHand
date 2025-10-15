// lib/view/screens/appointments/widgets/reason_step.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
import 'appointment_step_layout.dart';

class ReasonStep extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const ReasonStep({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return AppointmentStepLayout(
      icon: HugeIcons.strokeRoundedNote,
      title: 'cuntanos_sobre_tu_consulta'.tr(),
      subtitle: 'describe_brevemente_el_motivo_de_tu_visita_mdica'.tr(),
      content: CustomTextField(
        controller: controller,
        focusNode: focusNode,
        labelText: 'motivo_de_la_consulta'.tr(),
        hintText: 'ej_dolor_de_cabeza_chequeo_general_molestias'.tr(),
        icon: HugeIcons.strokeRoundedNote,
        maxLines: 5,
        iconColor: AppColors.accentColor(context),
        focusedBorderColor: AppColors.accentColor(context),
      ),
    );
  }
}