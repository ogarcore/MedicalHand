// lib/view/widgets/appointment/appointment_status_chip.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';

class AppointmentStatusChip extends StatelessWidget {
  final String status;

  const AppointmentStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    const Color chipTextColor = Colors.white;
    final Color chipBackgroundColor = Colors.white.withAlpha(40);
    IconData? icon;

    // Formatea el texto del estado para mostrarlo al usuario.
    final displayStatus = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ')
        : '';

    switch (status) {
      case 'no_asistio':
        icon = HugeIcons.strokeRoundedCalendarRemove02;
        break;
      case 'confirmada':
        icon = HugeIcons.strokeRoundedTickDouble01;
        break;
      case 'pendiente':
        icon = HugeIcons.strokeRoundedClock01;
        break;
      case 'finalizada':
        icon = HugeIcons.strokeRoundedCheckmarkSquare03;
        break;
      case 'cancelada':
        icon = HugeIcons.strokeRoundedCancelCircleHalfDot;
        break;
      case 'pendiente_reprogramacion':
        icon = HugeIcons.strokeRoundedRepeat;
        break;
      default:
        icon = HugeIcons.strokeRoundedHelpSquare;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: chipBackgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.white.withAlpha(80), width: 0.5.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: chipTextColor),
          SizedBox(width: 4.w),
          Text(
            displayStatus,
            style: TextStyle(
              color: chipTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}