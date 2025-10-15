// lib/view/widgets/appointment/info_row.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final int maxLines;

  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.primaryColor(context)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textLightColor(context),
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}