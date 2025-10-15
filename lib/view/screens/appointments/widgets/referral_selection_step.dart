// lib/view/screens/appointments/widgets/referral_selection_step.dart
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view/widgets/custom_dropdown.dart';
import 'appointment_step_layout.dart';

class ReferralSelectionStep extends StatelessWidget {
  final File? referralImage;
  final bool isDigitalReferral;
  final String? selectedSpecialty;
  final List<String> specialties;
  final VoidCallback onPickImage;
  final VoidCallback onSelectDigitalReferral;
  final VoidCallback onResetReferral;
  final ValueChanged<String?> onSpecialtyChanged;

  const ReferralSelectionStep({
    super.key,
    this.referralImage,
    required this.isDigitalReferral,
    this.selectedSpecialty,
    required this.specialties,
    required this.onPickImage,
    required this.onSelectDigitalReferral,
    required this.onResetReferral,
    required this.onSpecialtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasReferral = referralImage != null || isDigitalReferral;

    return AppointmentStepLayout(
      icon: HugeIcons.strokeRoundedDocumentValidation,
      iconColor: AppColors.accentColor(context),
      title: 'adjunta_tu_referencia'.tr(),
      subtitle: 'selecciona_una_referencia_digital'.tr(),
      content: Column(
        children: [
          if (!hasReferral)
            _buildReferralOptions(context)
          else
            _buildAttachmentConfirmation(context),
          if (hasReferral) ...[
            SizedBox(height: 16.h),
            AppStyledDropdown(
              value: selectedSpecialty,
              items: specialties,
              hintText: 'selecciona_la_especialidad'.tr(),
              prefixIcon: HugeIcons.strokeRoundedStethoscope,
              onChanged: onSpecialtyChanged,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReferralOptions(BuildContext context) {
    return Column(
      children: [
        _buildOptionCard(
          context: context,
          icon: HugeIcons.strokeRoundedCamera01,
          title: 'subir_foto_de_referencia'.tr(),
          subtitle: 'toma_o_selecciona_una_foto_de_tu_galera'.tr(),
          onTap: onPickImage,
        ),
        SizedBox(height: 12.h),
        _buildOptionCard(
          context: context,
          icon: HugeIcons.strokeRoundedInbox,
          title: 'referencia_digital'.tr(),
          subtitle: 'selecciona_de_tu_bandeja_de_entrada'.tr(),
          onTap: onSelectDigitalReferral,
        ),
      ],
    );
  }

  Widget _buildAttachmentConfirmation(BuildContext context) {
    final bool isImage = referralImage != null;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.successColor(context).withAlpha(15),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.successColor(context).withAlpha(60),
          width: 1.5.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: AppColors.successColor(context).withAlpha(20),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: isImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.file(referralImage!, fit: BoxFit.cover))
                : Icon(HugeIcons.strokeRoundedFolder01,
                    color: AppColors.successColor(context), size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isImage ? "Foto cargada" : 'referencia_digital'.tr(),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor(context),
                      fontSize: 14.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  isImage
                      ? "Referencia adjuntada correctamente"
                      : 'seleccionada_de_tu_bandeja'.tr(),
                  style: TextStyle(
                      color: AppColors.textLightColor(context),
                      fontSize: 12.sp,
                      height: 1.2),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close,
                color: AppColors.textLightColor(context).withAlpha(150),
                size: 18.sp),
            onPressed: onResetReferral,
            splashRadius: 18.r,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.withAlpha(40)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: AppColors.accentColor(context).withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 20.sp, color: AppColors.accentColor(context)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor(context))),
                  SizedBox(height: 2.h),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textLightColor(context),
                          height: 1.2)),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.textLightColor(context).withAlpha(120),
                size: 20.sp),
          ],
        ),
      ),
    );
  }
}