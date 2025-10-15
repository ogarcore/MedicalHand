// lib/view/screens/family/widgets/edit_enhanced_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class EditEnhancedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData icon;
  final bool readOnly;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? minLines;
  final int? maxLines;
  final Widget? suffixIcon;
  final Function(String)? onSubmitted;

  const EditEnhancedTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.icon,
    this.hintText,
    this.readOnly = false,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.minLines,
    this.maxLines = 1,
    this.suffixIcon,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      minLines: minLines,
      maxLines: maxLines,
      onFieldSubmitted: onSubmitted,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        suffixIcon: suffixIcon,
        labelStyle: TextStyle(
          color: AppColors.accentColor(context),
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        prefixIcon: Container(
          margin: EdgeInsets.all(12.r),
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: AppColors.accentColor(context).withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20.sp, color: AppColors.accentColor(context)),
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide:
              BorderSide(color: AppColors.accentColor(context), width: 2.w),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
    );
  }
}