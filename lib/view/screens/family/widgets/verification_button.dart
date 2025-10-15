// lib/view/screens/family/widgets/verification_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class VerificationButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final bool isSelected;

  const VerificationButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryColor(context).withAlpha(20)
            : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryColor(context)
              : Colors.grey.shade300,
          width: isSelected ? 1.5.w : 1.w,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primaryColor(context)
                        : AppColors.primaryColor(context).withAlpha(20),
                  ),
                  child: Icon(
                    icon,
                    size: 20.sp,
                    color: isSelected
                        ? Colors.white
                        : AppColors.primaryColor(context),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryColor(context)
                          : AppColors.textColor(context),
                    ),
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  color: isSelected
                      ? AppColors.successColor(context)
                      : Colors.grey.shade400,
                  size: 22.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}