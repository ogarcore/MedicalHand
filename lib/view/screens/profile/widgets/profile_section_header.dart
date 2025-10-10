import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class ProfileSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onEditPressed;

  const ProfileSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);
    final secondayColor = AppColors.secondaryColor(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12,top: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  Color.lerp(primaryColor, Colors.white, 0.3)!,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withAlpha(40),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor(context),
              ),
            ),
          ),
          if (onEditPressed != null)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: primaryColor.withAlpha(40),
                  width: 1.2,
                ),
              ),
              child: IconButton(
                onPressed: onEditPressed,
                icon: Icon(
                  HugeIcons.strokeRoundedEdit01,
                  size: 18,
                  color: secondayColor,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );
  }
}