// lib/view/screens/family/widgets/contact_info_section.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/utils/input_formatters.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
import 'package:p_hn25/view_model/family_view_model.dart';
import 'form_section_container.dart';

class ContactInfoSection extends StatelessWidget {
  final FamilyViewModel familyViewModel;
  final bool isPhoneOptional;

  const ContactInfoSection({
    super.key,
    required this.familyViewModel,
    required this.isPhoneOptional,
  });

  @override
  Widget build(BuildContext context) {
    return FormSectionContainer(
      title: 'informacin_de_contacto'.tr(),
      icon: HugeIcons.strokeRoundedContactBook,
      children: [
        CustomTextField(
          controller: familyViewModel.phoneController,
          labelText: isPhoneOptional ? 'Teléfono (Opcional)' : 'Teléfono',
          hintText: '0000-0000',
          icon: HugeIcons.strokeRoundedTelephone,
          keyboardType: TextInputType.phone,
          inputFormatters: [PhoneInputFormatter()],
          validator: isPhoneOptional
              ? AppValidators.validateOptionalPhone
              : AppValidators.validatePhone,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: familyViewModel.addressController,
          labelText: 'direccin'.tr(),
          hintText: 'direccin_de_domicilio'.tr(),
          icon: HugeIcons.strokeRoundedLocation01,
          validator: (value) => AppValidators.validateGenericEmpty(value, 'La dirección'),
        ),
      ],
    );
  }
}