// lib/view/screens/home/widgets/notification_icon_button.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class NotificationIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const NotificationIconButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(25),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              HugeIcons.strokeRoundedNotification03,
              color: AppColors.textColor.withAlpha(204),
              size: 25,
            ),
          ),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.warningColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
