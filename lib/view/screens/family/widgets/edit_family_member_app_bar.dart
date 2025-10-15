// lib/view/screens/family/widgets/edit_family_member_app_bar.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class EditFamilyMemberAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EditFamilyMemberAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('editar_info_familiar'.tr()),
      backgroundColor: AppColors.accentColor(context),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25.r)),
      ),
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(51),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}