// lib/view/screens/login/widgets/login_background.dart
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor(context).withAlpha(30),
                AppColors.backgroundColor(context),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: -size.height * 0.25,
          left: -size.width * 0.2,
          child: Container(
            width: size.width * 0.8,
            height: size.width * 0.8,
            decoration: BoxDecoration(
              color: AppColors.primaryColor(context).withAlpha(15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor(context).withAlpha(60),
                  blurRadius: 40,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -size.height * 0.2,
          right: -size.width * 0.2,
          child: Container(
            width: size.width * 0.65,
            height: size.width * 0.65,
            decoration: BoxDecoration(
              color: AppColors.primaryColor(context).withAlpha(10),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor(context).withAlpha(80),
                  blurRadius: 50,
                  spreadRadius: 30,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
