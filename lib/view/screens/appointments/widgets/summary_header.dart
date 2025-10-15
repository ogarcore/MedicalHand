// lib/view/screens/appointments/widgets/summary_header.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class SummaryHeader extends StatelessWidget {
  const SummaryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20.h),
        Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryColor(context).withAlpha(20),
            border: Border.all(
              color: AppColors.primaryColor(context).withAlpha(40),
              width: 1.5.w,
            ),
          ),
          child: Icon(
            HugeIcons.strokeRoundedTask01,
            size: 26.sp,
            color: AppColors.primaryColor(context),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'revisa_tu_solicitud'.tr(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textColor(context),
          ),
        ),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0.w),
          child: Text(
            'confirma_que_los_datos_de_tu_cita_son_correctos'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textLightColor(context),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}