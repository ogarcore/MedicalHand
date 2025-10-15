// lib/view/widgets/common/gradient_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const GradientAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryColor(context).withAlpha(243),
            AppColors.primaryColor(context).withAlpha(217),
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor(context).withAlpha(76),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}