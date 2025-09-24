import 'package:flutter/material.dart';
import '../../../app/core/constants/app_colors.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? shadowColor;
  final BorderSide? side;
  final double? borderWidth;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.shadowColor,
    this.side,
    this.borderWidth,
    this.height,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? AppColors.primaryColor(context),
          side:
              side ??
              BorderSide(
                color: foregroundColor ?? AppColors.primaryColor(context),
                width: borderWidth ?? 1.8,
              ),
          padding:
              padding ??
              const EdgeInsets.symmetric(vertical: 14, horizontal: 95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          shadowColor:
              shadowColor ?? AppColors.primaryColor(context).withAlpha(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 6)],
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
