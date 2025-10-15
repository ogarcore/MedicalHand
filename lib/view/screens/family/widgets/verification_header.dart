// lib/view/screens/family/widgets/verification_header.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class VerificationHeader extends StatelessWidget {
  final bool isMinor;

  const VerificationHeader({super.key, required this.isMinor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.primaryColor(context).withAlpha(15),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryColor(context).withAlpha(40),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor(context).withAlpha(30),
            ),
            child: Icon(
              HugeIcons.strokeRoundedShield01,
              size: 24.sp,
              color: AppColors.primaryColor(context),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMinor
                      ? 'Identificación del Menor'
                      : 'identificacin_del_familiar'.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor(context),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isMinor
                      ? 'Completa la información de identificación del menor'
                      : 'verifica_la_identidad_de_tu_familiar'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textLightColor(context),
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