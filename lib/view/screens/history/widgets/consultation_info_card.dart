import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:p_hn25/app/core/constants/app_colors.dart';

class ConsultationInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color accentColor;

  const ConsultationInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: isDark ? Colors.white.withAlpha(8) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : Colors.grey.shade100,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 12 : 4),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withAlpha(40),
                        accentColor.withAlpha(20),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: accentColor.withAlpha(30),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(icon, size: 16.sp, color: accentColor),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
            child: Column(
              children: [
                Container(
                  height: 1,
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        isDark
                            ? Colors.white.withAlpha(30)
                            : Colors.grey.shade300,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.5,
                      color: AppColors.textColor(context).withAlpha(220),
                      fontWeight: FontWeight.w400,
                    ),
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