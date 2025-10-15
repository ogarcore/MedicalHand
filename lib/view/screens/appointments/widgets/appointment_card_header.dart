// lib/view/widgets/appointment/appointment_card_header.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/cita_model.dart';
import 'package:p_hn25/view/screens/appointments/widgets/appointment_status_chip.dart';

class AppointmentCardHeader extends StatelessWidget {
  final CitaModel cita;

  const AppointmentCardHeader({
    super.key,
    required this.cita,
  });

  // Determina el color del degradado basado en el estado de la cita.
  List<Color> _getHeaderGradientColors(BuildContext context) {
    switch (cita.status) {
      case 'no_asistio':
        final primaryColor = AppColors.textLightColor(context).withAlpha(220);
        return [
          primaryColor,
          Color.lerp(primaryColor.withAlpha(210),
              const Color.fromARGB(255, 88, 88, 88), 0.3)!
        ];
      case 'confirmada':
      case 'asistencia_confirmada':
        final primaryColor = AppColors.primaryColor(context);
        return [
          primaryColor,
          Color.lerp(primaryColor, Colors.blue.shade700, 0.3)!
        ];
      case 'cancelada':
        final warningColor = AppColors.warningColor(context);
        return [
          warningColor.withAlpha(230),
          Color.lerp(warningColor.withAlpha(220), Colors.black, 0.1)!
        ];
      case 'pendiente':
        final graceColor = AppColors.graceColor(context);
        return [
          Color.lerp(graceColor.withAlpha(180), Colors.black, 0.08)!,
          graceColor.withAlpha(200),
          Color.lerp(graceColor.withAlpha(180), Colors.brown, 0.2)!
        ];
      case 'finalizada':
        final secondaryColor = AppColors.secondaryColor(context);
        return [
          secondaryColor.withAlpha(200),
          Color.lerp(AppColors.primaryColor(context).withAlpha(200),
              Colors.black, 0.15)!
        ];
      case 'pendiente_reprogramacion':
        final accentColor = AppColors.accentColor(context);
        return [
          accentColor,
          Color.lerp(accentColor, Colors.indigo.shade900, 0.3)!
        ];
      default:
        return [Colors.grey.shade800, Colors.black];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getHeaderGradientColors(context),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withAlpha(40),
                  Colors.white.withAlpha(20),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withAlpha(60),
                width: 1.5.w,
              ),
            ),
            child: Icon(
              HugeIcons.strokeRoundedHospital01,
              color: Colors.white.withAlpha(220),
              size: 16.5.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              cita.specialty ?? 'consulta_externa'.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white.withAlpha(240),
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          AppointmentStatusChip(status: cita.status),
        ],
      ),
    );
  }
}