// lib/view/screens/appointments/widgets/appointment_options_header.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class AppointmentOptionsHeader extends StatelessWidget {
  final bool isSmallScreen;

  const AppointmentOptionsHeader({
    super.key,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: isSmallScreen ? 8.h : 12.h),
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.primaryColor(context).withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(
            HugeIcons.strokeRoundedCalendar01,
            color: AppColors.primaryColor(context),
            size: isSmallScreen ? 24.sp : 28.sp,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8.h : 12.h),
        Text(
          'qué_tipo_de_cita_necesitas'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textColor(context),
          ),
        ),
        SizedBox(height: isSmallScreen ? 4.h : 6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0.w),
          child: Text(
            'selecciona_la_opcin_segn_tu_necesidad_mdica'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textLightColor(context),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}