import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:p_hn25/app/core/constants/app_colors.dart';

class ConsultationListCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List items;
  final Widget Function(Map<String, dynamic>) itemBuilder;
  final Color accentColor;

  const ConsultationListCard({
    super.key,
    required this.icon,
    required this.title,
    required this.items,
    required this.itemBuilder,
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
                  margin: EdgeInsets.only(bottom: 10.h),
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
                ...items.asMap().entries.map((entry) {
                  final item = Map<String, dynamic>.from(entry.value as Map);
                  final isLast = entry.key == items.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 5.w,
                          height: 5.h,
                          margin: EdgeInsets.only(top: 8.h),
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              color: isDark
                                  ? Colors.white.withAlpha(6)
                                  : Colors.grey.shade50,
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withAlpha(12)
                                    : Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: itemBuilder(item),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}