// lib/view/screens/appointments/widgets/appointments_app_bar.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class AppointmentsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final bool areFiltersActive;
  final VoidCallback onFilterPressed;

  const AppointmentsAppBar({
    super.key,
    required this.tabController,
    required this.areFiltersActive,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.backgroundColor(context),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 2.h),
          Text(
            'mis_citas'.tr(),
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor(context),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'tus_citas_organizadas_en_un_solo_lugar'.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.normal,
              color: AppColors.textLightColor(context),
            ),
          ),
          SizedBox(height: 4.h),
        ],
      ),
      actions: [
        if (tabController.index == 1)
          Padding(
            padding: EdgeInsets.only(right: 8.0.w),
            child: IconButton(
              icon: Icon(
                areFiltersActive
                    ? HugeIcons.strokeRoundedFilterEdit
                    : HugeIcons.strokeRoundedFilter,
                color: areFiltersActive
                    ? AppColors.warningColor(context)
                    : AppColors.primaryColor(context),
              ),
              onPressed: onFilterPressed,
              tooltip: 'filtrar_citas_pasadas'.tr(),
            ),
          ),
      ],
      bottom: TabBar(
        controller: tabController,
        labelColor: AppColors.primaryColor(context),
        unselectedLabelColor: Colors.grey[600],
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: AppColors.primaryColor(context).withAlpha(70),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 15.sp),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        tabs: [
          Tab(text: 'prximas'.tr()),
          Tab(text: 'pasadas'.tr()),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
}