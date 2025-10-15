// lib/view/screens/appointments/widgets/request_appointment_app_bar.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class RequestAppointmentAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const RequestAppointmentAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'solicitar_cita_mdica'.tr(),
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(22.r)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryColor(context).withAlpha(243),
              AppColors.primaryColor(context).withAlpha(217),
            ],
          ),
        ),
      ),
      elevation: 1,
      shadowColor: const Color.fromARGB(100, 0, 0, 0),
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}