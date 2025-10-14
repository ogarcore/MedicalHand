import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor(context).withAlpha(50),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.supervised_user_circle,
              size: 60,
              color: AppColors.primaryColor(context),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Text(
          'bienvenido'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor(context),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'accede_a_tu_cuenta_para_continuar'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
