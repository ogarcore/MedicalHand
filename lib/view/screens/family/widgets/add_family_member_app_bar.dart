// lib/view/screens/family/widgets/add_family_member_app_bar.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class AddFamilyMemberAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const AddFamilyMemberAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'aadir_nuevo_familiar'.tr(),
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: AppColors.backgroundColor(context),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}