// lib/view/widgets/appointment/appointment_options_section.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class AppointmentOptionsSection extends StatefulWidget {
  final VoidCallback onReschedule;
  final VoidCallback onCancel;

  const AppointmentOptionsSection({
    super.key,
    required this.onReschedule,
    required this.onCancel,
  });

  @override
  State<AppointmentOptionsSection> createState() =>
      _AppointmentOptionsSectionState();
}

class _AppointmentOptionsSectionState extends State<AppointmentOptionsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 6.h),
      child: Column(
        children: [
          // Botón para expandir/colapsar las opciones.
          Align(
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0.h, horizontal: 12.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'opciones_de_la_cita'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentColor(context).withAlpha(220),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: _isExpanded ? 0.5 : 0,
                        child: Icon(
                          HugeIcons.strokeRoundedArrowDownDouble,
                          size: 16.sp,
                          color: AppColors.accentColor(context).withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Contenido animado que se muestra al expandir.
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Column(
              children: [
                if (_isExpanded)
                  Padding(
                    padding: EdgeInsets.only(
                      top: 8.0.h,
                      bottom: 8.h,
                      left: 4.w,
                      right: 4.w,
                    ),
                    child: Row(
                      children: [
                        _buildRescheduleButton(context),
                        SizedBox(width: 12.w),
                        _buildCancelButton(context),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRescheduleButton(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: widget.onReschedule,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentColor(context).withAlpha(200),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 1,
          shadowColor: AppColors.accentColor(context).withAlpha(100),
        ),
        child: Text(
          'reprogramar'.tr(),
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: widget.onCancel,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withAlpha(20),
          foregroundColor: AppColors.warningColor(context),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(
              color: AppColors.warningColor(context),
              width: 1.5.w,
            ),
          ),
          elevation: 0,
        ),
        child: Text(
          'cancelar'.tr(),
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
        ),
      ),
    );
  }
}