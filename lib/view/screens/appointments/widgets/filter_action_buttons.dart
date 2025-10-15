// lib/view/widgets/filters/filter_action_buttons.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class FilterActionButtons extends StatelessWidget {
  final bool hasActiveFilters;
  final VoidCallback onClear;
  final VoidCallback onApply;

  const FilterActionButtons({
    super.key,
    required this.hasActiveFilters,
    required this.onClear,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            // Si no hay filtros activos, onPressed es null, desactivando el botón.
            onPressed: hasActiveFilters ? onClear : null,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              side: BorderSide(
                color: hasActiveFilters
                    ? AppColors.warningColor(context)
                    : Colors.grey.shade300,
              ),
            ),
            child: Text(
              'limpiar'.tr(),
              style: TextStyle(
                color: hasActiveFilters
                    ? AppColors.warningColor(context)
                    : Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton(
            onPressed: onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 2,
            ),
            child: Text(
              'aplicar'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}