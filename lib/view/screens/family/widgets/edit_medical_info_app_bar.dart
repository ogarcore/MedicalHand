// lib/view/screens/family/widgets/edit_medical_info_app_bar.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/user_model.dart';

class EditMedicalInfoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel member;

  const EditMedicalInfoAppBar({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('info_medica_de'.tr(args: [member.firstName])),
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