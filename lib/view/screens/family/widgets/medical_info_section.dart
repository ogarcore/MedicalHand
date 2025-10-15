// lib/view/screens/family/widgets/medical_info_section.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
import 'package:p_hn25/view_model/family_view_model.dart';
import 'form_section_container.dart';

class MedicalInfoSection extends StatelessWidget {
  final FamilyViewModel familyViewModel;

  const MedicalInfoSection({
    super.key,
    required this.familyViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return FormSectionContainer(
      title: 'Información Médica (Opcional)',
      icon: HugeIcons.strokeRoundedHealth,
      children: [
        CustomTextField(
          controller: familyViewModel.bloodTypeController,
          labelText: 'tipo_de_sangre'.tr(),
          hintText: 'Ej: O+',
          icon: HugeIcons.strokeRoundedBloodBag,
          validator: AppValidators.validateOptionalBloodType,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: familyViewModel.allergiesController,
          labelText: 'alergias_conocidas'.tr(),
          hintText: 'ej_penicilina'.tr(),
          icon: HugeIcons.strokeRoundedMedicalMask,
          maxLines: 3,
        ),
      ],
    );
  }
}