// lib/view/screens/appointments/widgets/summary_details_card.dart
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class SummaryDetailsCard extends StatelessWidget {
  final String departament;
  final String hospitalName;
  final String? specialty;
  final String reason;
  final File? referralImage;

  const SummaryDetailsCard({
    super.key,
    required this.departament,
    required this.hospitalName,
    this.specialty,
    required this.reason,
    this.referralImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            context: context,
            icon: HugeIcons.strokeRoundedLocation04,
            label: 'departamento'.tr(),
            value: departament,
          ),
          _buildDivider(),
          _buildSummaryRow(
            context: context,
            icon: HugeIcons.strokeRoundedHospital01,
            label: 'centro_mdico'.tr(),
            value: hospitalName,
          ),
          if (specialty != null && specialty!.isNotEmpty) ...[
            _buildDivider(),
            _buildSummaryRow(
              context: context,
              icon: HugeIcons.strokeRoundedStethoscope,
              label: 'especialidad_solicitada'.tr(),
              value: specialty!,
            ),
          ],
          _buildDivider(),
          _buildSummaryRow(
            context: context,
            icon: HugeIcons.strokeRoundedNote,
            label: 'motivo_de_consulta'.tr(),
            value: reason,
            isMultiline: true,
          ),
          if (referralImage != null) ...[
            _buildDivider(),
            _buildSummaryImageRow(context, referralImage!),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Divider(height: 1.h, color: Colors.grey.withAlpha(40)),
    );
  }

  Widget _buildSummaryRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment:
          isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppColors.primaryColor(context).withAlpha(15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryColor(context), size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textLightColor(context),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textColor(context),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  height: isMultiline ? 1.3 : 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryImageRow(BuildContext context, File image) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppColors.primaryColor(context).withAlpha(15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            HugeIcons.strokeRoundedImage01,
            color: AppColors.primaryColor(context),
            size: 18.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'foto_de_referencia_adjunta'.tr(),
                style: TextStyle(
                  color: AppColors.textLightColor(context),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.all(10.r),
                      child: InteractiveViewer(child: Image.file(image)),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8.0.r),
                child: Hero(
                  tag: 'referralImage',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0.r),
                    child: Image.file(
                      image,
                      height: 120.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}