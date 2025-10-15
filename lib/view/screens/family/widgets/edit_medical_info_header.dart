// lib/view/screens/family/widgets/edit_medical_info_header.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class EditMedicalInfoHeader extends StatelessWidget {
  const EditMedicalInfoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(20.r),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentColor(context).withAlpha(26),
            AppColors.accentColor(context).withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.accentColor(context).withAlpha(51),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accentColor(context),
                  AppColors.accentColor(context).withAlpha(204),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentColor(context).withAlpha(77),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(HugeIcons.strokeRoundedCovidInfo,
                color: Colors.white, size: 28.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'editar_informacin_mdica'.tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentColor(context),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'esta_informacin_es_crucial_en_caso_de_emergencias_mdicas'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}