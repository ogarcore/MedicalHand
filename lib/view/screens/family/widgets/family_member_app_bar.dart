// lib/view/screens/family/widgets/family_member_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FamilyMemberAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String memberName;
  const FamilyMemberAppBar({super.key, required this.memberName});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'Perfil de $memberName',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 22.sp,
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}