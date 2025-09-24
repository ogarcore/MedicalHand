// lib/view/screens/profile/widgets/settings_row.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class SettingsRow extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const SettingsRow({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17.0, horizontal: 8.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.textColor(context),
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
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
