// lib/view/screens/appointments/widgets/summary_app_bar.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class SummaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SummaryAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'resumen_de_cita'.tr(),
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor(context),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withAlpha(30),
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.textColor(context)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.r)),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}