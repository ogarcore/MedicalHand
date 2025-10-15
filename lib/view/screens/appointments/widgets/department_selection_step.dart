// lib/view/screens/appointments/widgets/department_selection_step.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view/widgets/custom_dropdown.dart';
import 'appointment_step_layout.dart';

class DepartmentSelectionStep extends StatelessWidget {
  final String? selectedDepartment;
  final List<String> departmentsList;
  final ValueChanged<String?> onChanged;

  const DepartmentSelectionStep({
    super.key,
    required this.selectedDepartment,
    required this.departmentsList,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppointmentStepLayout(
      icon: HugeIcons.strokeRoundedLocation04,
      title: 'en_qué_departamento_te_encuentras'.tr(),
      subtitle:
          'selecciona_tu_ubicacin_para_mostrarte_los_hospital_de_tu_zon'.tr(),
      iconColor: AppColors.primaryColor(context),
      content: AppStyledDropdown(
        value: selectedDepartment,
        items: departmentsList,
        hintText: 'selecciona_t_departamento'.tr(),
        prefixIcon: HugeIcons.strokeRoundedLocation04,
        iconColor: AppColors.accentColor(context),
        iconBackgroundColor: AppColors.accentColor(context).withAlpha(30),
        onChanged: onChanged,
      ),
    );
  }
}