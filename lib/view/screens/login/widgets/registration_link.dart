// lib/view/screens/login/widgets/registration_link.dart
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view/screens/registration/registration_step1_screen.dart';

class RegistrationLink extends StatelessWidget {
  const RegistrationLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes una cuenta?',
          style: TextStyle(color: Colors.grey[700], fontSize: 15),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegistrationStep1Screen(),
              ),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryColor(context),
          ),
          child: Text(
            'Regístrate',
            style: TextStyle(
              color: AppColors.primaryColor(context),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
