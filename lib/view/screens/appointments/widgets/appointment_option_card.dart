// lib/view/screens/appointments/widgets/appointment_option_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view/widgets/primary_button.dart';
import 'package:p_hn25/view/widgets/secondary_button.dart';

class AppointmentOptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final List<String>? details;
  final String buttonText;
  final VoidCallback onPressed;
  final bool isHighlighted;
  final bool isSmallScreen;

  const AppointmentOptionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.details,
    required this.buttonText,
    required this.onPressed,
    this.isHighlighted = false,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16.r : 18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isHighlighted ? 20 : 12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isHighlighted
              ? AppColors.accentColor(context).withAlpha(51)
              : Colors.transparent,
          width: 1.5.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Se pasa el 'context' al método.
          _buildCardHeader(context),
          SizedBox(height: isSmallScreen ? 8.h : 10.h),
          Text(
            description,
            style: TextStyle(
              fontSize: isSmallScreen ? 12.sp : 13.sp,
              color: AppColors.textLightColor(context),
              height: 1.3,
            ),
          ),
          if (details != null) _buildDetailsList(context),
          SizedBox(height: isSmallScreen ? 12.h : 14.h),
          // Se pasa el 'context' al método.
          _buildActionButton(context),
        ],
      ),
    );
  }

  // Se recibe 'context' como parámetro.
  Widget _buildCardHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: isSmallScreen ? 40.w : 44.w,
          height: isSmallScreen ? 40.w : 44.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [iconColor.withAlpha(38), iconColor.withAlpha(64)],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: isSmallScreen ? 18.sp : 20.sp,
          ),
        ),
        SizedBox(width: isSmallScreen ? 12.w : 14.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 16.sp : 17.sp,
              fontWeight: FontWeight.w700,
              // Ya no se necesita el cast 'as BuildContext'.
              color: AppColors.textColor(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsList(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: isSmallScreen ? 8.h : 10.h),
      child: Column(
        children: details!
            .map((detail) => Padding(
                  padding: EdgeInsets.only(bottom: isSmallScreen ? 4.h : 5.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 5.h, right: 6.w),
                        child: Icon(
                          Icons.circle,
                          size: 5.sp,
                          color: AppColors.accentColor(context),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          detail,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11.sp : 12.sp,
                            color: AppColors.textLightColor(context),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  // Se recibe 'context' como parámetro.
  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: isSmallScreen ? 45.h : 50.h,
      child: isHighlighted
          ? SecondaryButton(
              text: buttonText,
              onPressed: onPressed,
              // Ya no se necesita el cast 'as BuildContext'.
              foregroundColor: AppColors.accentColor(context),
              shadowColor: AppColors.accentColor(context).withAlpha(30),
              side: BorderSide(
                color: AppColors.accentColor(context),
                width: 1.w,
              ),
            )
          : PrimaryButton(text: buttonText, onPressed: onPressed),
    );
  }
}