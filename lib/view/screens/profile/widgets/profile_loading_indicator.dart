import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class ProfileLoadingIndicator extends StatelessWidget {
  const ProfileLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryColor(context),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'cargando_perfil'.tr(),
            style: TextStyle(
              color: AppColors.textColor(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}