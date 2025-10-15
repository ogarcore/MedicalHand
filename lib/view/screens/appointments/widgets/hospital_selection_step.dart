// lib/view/screens/appointments/widgets/hospital_selection_step.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/data/models/hospital_model.dart';
import 'package:p_hn25/view/widgets/custom_dropdown.dart';
import 'appointment_step_layout.dart';

class HospitalSelectionStep extends StatelessWidget {
  final bool isLoading;
  final List<HospitalModel> hospitalsList;
  final HospitalModel? selectedHospital;
  final ValueChanged<String?> onChanged;

  const HospitalSelectionStep({
    super.key,
    required this.isLoading,
    required this.hospitalsList,
    required this.selectedHospital,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppointmentStepLayout(
      icon: HugeIcons.strokeRoundedHospital01,
      title: 'elige_tu_centro_mdico'.tr(),
      subtitle: 'elige_el_centro_mdico_donde_deseas_agendar_tu_cita'.tr(),
      content: _buildHospitalsDropdown(),
    );
  }

  Widget _buildHospitalsDropdown() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (hospitalsList.isEmpty) {
      return AppStyledDropdown(
        items: const [],
        hintText: 'no_se_encontraron_hospitales'.tr(),
        onChanged: (value) {},
        value: null,
        prefixIcon: HugeIcons.strokeRoundedHospital01,
        showDropdownIcon: false,
      );
    }
    return AppStyledDropdown(
      value: selectedHospital?.name,
      items: hospitalsList.map((hospital) => hospital.name).toList(),
      hintText: 'selecciona_un_hospital'.tr(),
      prefixIcon: HugeIcons.strokeRoundedHospital01,
      onChanged: onChanged,
    );
  }
}