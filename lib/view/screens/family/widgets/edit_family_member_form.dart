// lib/view/screens/family/widgets/edit_family_member_form.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/utils/input_formatters.dart';
import 'package:p_hn25/app/core/utils/validators.dart';

class EditFamilyMemberForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController idNumberController;
  final TextEditingController dobController;
  final TextEditingController phoneController;
  final TextEditingController addressController;

  const EditFamilyMemberForm({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.idNumberController,
    required this.dobController,
    required this.phoneController,
    required this.addressController,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Form(
          key: formKey,
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(16),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _buildCompactLayout();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLayout() {
    return Column(
      children: [
        _EnhancedTextField(
          controller: firstNameController,
          labelText: 'nombres'.tr(),
          icon: HugeIcons.strokeRoundedUser,
          validator: (v) => AppValidators.validateGenericEmpty(v, 'nombres'.tr()),
        ),
        SizedBox(height: 20.h),
        _EnhancedTextField(
          controller: lastNameController,
          labelText: 'apellidos'.tr(),
          icon: HugeIcons.strokeRoundedUserCircle,
          validator: (v) => AppValidators.validateGenericEmpty(v, 'apellidos'.tr()),
        ),
        SizedBox(height: 20.h),
        _EnhancedTextField(
          controller: idNumberController,
          labelText: 'cdula_de_identidad'.tr(),
          icon: HugeIcons.strokeRoundedPassport,
          inputFormatters: [CedulaInputFormatter()],
          validator: AppValidators.validateCedula,
        ),
        SizedBox(height: 20.h),
        _EnhancedTextField(
          controller: dobController,
          labelText: 'fecha_de_nacimiento'.tr(),
          hintText: 'dd/MM/yyyy',
          icon: HugeIcons.strokeRoundedCalendar02,
          keyboardType: TextInputType.number,
          inputFormatters: [DateInputFormatter()],
          validator: AppValidators.validateBirthDate,
        ),
        SizedBox(height: 20.h),
        _EnhancedTextField(
          controller: phoneController,
          labelText: 'telfono'.tr(),
          icon: HugeIcons.strokeRoundedFlipPhone,
          inputFormatters: [PhoneInputFormatter()],
          keyboardType: TextInputType.phone,
          validator: AppValidators.validatePhone,
        ),
        SizedBox(height: 20.h),
        _EnhancedTextField(
          controller: addressController,
          labelText: 'direccin'.tr(),
          icon: HugeIcons.strokeRoundedLocation03,
          maxLines: 3,
          validator: (v) => AppValidators.validateGenericEmpty(v, 'La dirección'),
        ),
      ],
    );
  }
}

// Internal helper widget for styled text fields
class _EnhancedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final int? maxLines;

  const _EnhancedTextField({
    required this.controller,
    required this.labelText,
    required this.icon,
    this.hintText,
    this.validator,
    this.inputFormatters,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Colors.black87),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(
            color: AppColors.accentColor(context),
            fontSize: 14.sp,
            fontWeight: FontWeight.w600),
        prefixIcon: Container(
          margin: EdgeInsets.all(12.r),
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
              color: AppColors.accentColor(context).withAlpha(26),
              shape: BoxShape.circle),
          child: Icon(icon, size: 20.sp, color: AppColors.accentColor(context)),
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide:
                BorderSide(color: AppColors.accentColor(context), width: 2.w)),
        filled: true,
        fillColor: AppColors.backgroundColor(context),
      ),
    );
  }
}