import 'package:easy_localization/easy_localization.dart';
// lib/view/screens/login/widgets/login_form.dart
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
import 'package:p_hn25/view/widgets/primary_button.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLoginPressed;
  final VoidCallback onForgotPasswordPressed;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLoginPressed,
    required this.onForgotPasswordPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: emailController,
            labelText: 'correo_electrnico'.tr(),
            hintText: 'ingresa_tu_correo'.tr(),
            keyboardType: TextInputType.emailAddress,
            icon: Icons.email_outlined,
            validator: AppValidators.validateEmail,
          ),
          const SizedBox(height: 25),
          CustomTextField(
            controller: passwordController,
            labelText: 'contrasea'.tr(),
            hintText: 'ingresa_tu_contrasea'.tr(),
            isPassword: true,
            icon: Icons.lock_outline,
            validator: (value) =>
                AppValidators.validateGenericEmpty(value, 'La contraseña'),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPasswordPressed,
              child: Text(
                'olvidaste_tu_contraseña'.tr(),
                style: TextStyle(
                  color: AppColors.primaryColor(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            text: 'iniciar_sesin'.tr(),
            isLoading: isLoading,
            onPressed: onLoginPressed,
          ),
        ],
      ),
    );
  }
}
