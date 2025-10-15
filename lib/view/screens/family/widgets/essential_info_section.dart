// lib/view/screens/family/widgets/essential_info_section.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/utils/input_formatters.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/view/widgets/custom_dropdown.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
import 'package:p_hn25/view_model/family_view_model.dart';
import 'form_section_container.dart';

class EssentialInfoSection extends StatelessWidget {
  final FamilyViewModel familyViewModel;
  final ValueChanged<String> onDateChanged;

  const EssentialInfoSection({
    super.key,
    required this.familyViewModel,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormSectionContainer(
      title: 'informacin_esencial'.tr(),
      icon: HugeIcons.strokeRoundedUserWarning01,
      children: [
        AppStyledDropdown(
          value: familyViewModel.selectedKinship,
          items: const ['Madre', 'Padre', 'Hijo/a', 'Cónyuge', 'Abuelo/a', 'Otro'],
          onChanged: (newValue) => familyViewModel.updateSelectedKinship(newValue),
          hintText: 'parentesco'.tr(),
          prefixIcon: HugeIcons.strokeRoundedUserGroup,
          validator: (value) => value == null ? 'Selecciona un parentesco' : null,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: familyViewModel.firstNameController,
          labelText: 'nombres'.tr(),
          hintText: 'nombres_del_familiar'.tr(),
          icon: HugeIcons.strokeRoundedUser,
          validator: (value) => AppValidators.validateGenericEmpty(value, 'El nombre'),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: familyViewModel.lastNameController,
          labelText: 'apellidos'.tr(),
          hintText: 'apellidos_del_familiar'.tr(),
          icon: HugeIcons.strokeRoundedUser,
          validator: (value) => AppValidators.validateGenericEmpty(value, 'El apellido'),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: familyViewModel.birthDateController,
          labelText: 'fecha_de_nacimiento'.tr(),
          hintText: 'DD/MM/AAAA',
          icon: HugeIcons.strokeRoundedCalendar01,
          keyboardType: TextInputType.number,
          inputFormatters: [DateInputFormatter()],
          validator: AppValidators.validateBirthDate,
          onChanged: onDateChanged,
        ),
      ],
    );
  }
}