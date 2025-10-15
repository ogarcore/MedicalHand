import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:p_hn25/app/core/constants/app_colors.dart';

class ConsultationDetailHeader extends StatelessWidget {
  final String hospital;
  final String date;
  final String doctor;
  final String specialty;

  const ConsultationDetailHeader({
    super.key,
    required this.hospital,
    required this.date,
    required this.doctor,
    required this.specialty,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primaryColor(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: isDark ? Colors.white.withAlpha(8) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : Colors.grey.shade100,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 15 : 5),
            blurRadius: 12.r,
            offset: const Offset(0, 3),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(isDark ? 25 : 12),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: primaryColor.withAlpha(isDark ? 40 : 20),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  HugeIcons.strokeRoundedArcBrowser,
                  size: 12.sp,
                  color: primaryColor,
                ),
                SizedBox(width: 6.w),
                Text(
                  specialty,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withAlpha(30),
                      primaryColor.withAlpha(15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: primaryColor.withAlpha(25),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  HugeIcons.strokeRoundedHospital01,
                  size: 18.sp,
                  color: primaryColor,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor(context),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'centro_mdico'.tr(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textColor(context).withAlpha(130),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildCompactDetailCard(
                  context,
                  icon: HugeIcons.strokeRoundedCalendar01,
                  title: 'fecha'.tr(),
                  value: date,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildCompactDetailCard(
                  context,
                  icon: HugeIcons.strokeRoundedDoctor01,
                  title: 'mdico'.tr(),
                  value: doctor,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDetailCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: isDark ? Colors.white.withAlpha(6) : color.withAlpha(6),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(12) : color.withAlpha(15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: color),
              SizedBox(width: 4.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor(context),
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}