// lib/view/widgets/filters/filter_bottom_sheet_header.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class FilterBottomSheetHeader extends StatelessWidget {
  const FilterBottomSheetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);
    return Row(
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor,
                Color.lerp(primaryColor, Colors.white, 0.2)!,
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            HugeIcons.strokeRoundedFilter,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'filtrar_citas_pasadas'.tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor(context),
                ),
              ),
              Text(
                'selecciona_los_criterios'.tr(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}