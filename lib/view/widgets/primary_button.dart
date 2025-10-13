import 'package:flutter/material.dart';
import '../../../app/core/constants/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Widget? icon;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final bool iconAtEnd;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.height,
    this.width,
    this.padding,
    this.iconAtEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    // 🔹 Medidas responsivas
    final screenWidth = MediaQuery.of(context).size.width;
    final responsivePadding = padding ??
        EdgeInsets.symmetric(
          vertical: screenWidth * 0.035,
          horizontal: screenWidth * 0.22,
        );
    final responsiveHeight = height ?? screenWidth * 0.13;

    return SizedBox(
      height: responsiveHeight,
      width: width ?? double.infinity, // ✅ ocupa todo el ancho si no se pasa width
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryColor(context),
          foregroundColor: Colors.white,
          padding: responsivePadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          shadowColor: (backgroundColor ?? AppColors.primaryColor(context))
              .withAlpha(80),
          alignment: Alignment.center,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: icon == null
                    ? [
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: screenWidth * 0.042,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ]
                    : iconAtEnd
                        ? [
                            Text(
                              text,
                              style: TextStyle(
                                fontSize: screenWidth * 0.042,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            icon!,
                          ]
                        : [
                            icon!,
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              text,
                              style: TextStyle(
                                fontSize: screenWidth * 0.042,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
              ),
      ),
    );
  }
}
