// lib/view/screens/family/widgets/account_settings_section.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view/screens/profile/widgets/info_card.dart';
import 'package:p_hn25/view/screens/profile/widgets/profile_section_header.dart';

class AccountSettingsSection extends StatelessWidget {
  final VoidCallback onDeletePressed;

  const AccountSettingsSection({super.key, required this.onDeletePressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileSectionHeader(
          title: 'configuracin_de_cuenta'.tr(),
          icon: HugeIcons.strokeRoundedSettings02,
        ),
        InfoCard(
          children: [
            _buildDeleteActionRow(context),
          ],
        ),
      ],
    );
  }

  Widget _buildDeleteActionRow(BuildContext context) {
    final color = AppColors.warningColor(context);
    return InkWell(
      onTap: onDeletePressed,
      borderRadius: BorderRadius.all(Radius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.0.h, horizontal: 16.0.w),
        child: Row(
          children: [
            Icon(HugeIcons.strokeRoundedDelete02, color: color, size: 22.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text('eliminar_perfil_familiar'.tr(),
                  style: TextStyle(
                      color: color,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600)),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade400, size: 16.sp),
          ],
        ),
      ),
    );
  }
}