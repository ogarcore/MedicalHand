// lib/view/widgets/appointment/past_appointment_finalized_content.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/cita_model.dart';
import 'package:p_hn25/view/screens/appointments/widgets/info_row.dart';

class PastAppointmentFinalizedContent extends StatelessWidget {
  final CitaModel cita;
  final VoidCallback onShowDetails;
  final String formattedDate;

  const PastAppointmentFinalizedContent({
    super.key,
    required this.cita,
    required this.onShowDetails,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cita.hospital,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textColor(context),
            letterSpacing: -0.2,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 6.h),
        InfoRow(icon: HugeIcons.strokeRoundedCalendar01, text: formattedDate),
        SizedBox(height: 6.h),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onShowDetails,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryColor(context),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'ver_detalles'.tr(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.5.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}