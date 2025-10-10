// lib/view/screens/profile/widgets/settings_row.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class SettingsRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;

  const SettingsRow({
    super.key, 
    required this.title,
    required this.icon,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.only(
          top: isFirst ? 12 : 17,
          bottom: isLast ? 12 : 17,
          left: 8,
          right: 8,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryColor(context).withAlpha(15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: AppColors.primaryColor(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.textColor(context),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              HugeIcons.strokeRoundedArrowRightDouble,
              size: 14.5,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}