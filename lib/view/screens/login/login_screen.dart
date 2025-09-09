// lib/view/screens/login/login_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/view/widgets/custom_modal.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import '../../../view_model/auth_view_model.dart';
import '../home/home_screen.dart';
import '../../../app/core/constants/app_colors.dart';

// Importa los nuevos widgets que creaste
import 'widgets/login_background.dart';
import 'widgets/login_header.dart';
import 'widgets/login_form.dart';
import 'widgets/social_login_section.dart';
import 'widgets/registration_link.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isGoogleLoading = false;

  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return CustomModal(
          icon: HugeIcons.strokeRoundedSquareLockPassword,
          title: 'Recuperar Contraseña',
          subtitle:
              'Introduce el correo electrónico asociado a tu cuenta para enviarte un enlace de recuperación.',
          content: CustomTextField(
            controller: resetEmailController,
            labelText: 'Correo Electrónico',
            hintText: 'Ingresa el correo de tu cuenta',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            ModalButton(
              text: 'Cancelar',
              onPressed: () => Navigator.pop(context),
            ),
            ModalButton(
              text: 'Enviar Enlace',
              isPrimary: true,
              onPressed: () async {
                if (resetEmailController.text.isEmpty) return;
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final error = await authViewModel.sendPasswordResetLink(
                  resetEmailController.text.trim(),
                );
                if (!mounted) return;
                navigator.pop(); // Cierra el modal
                if (error == null) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Enlace de recuperación enviado a tu correo.',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(error),
                      backgroundColor: AppColors.warningColor,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      final success = await authViewModel.signInUser(
        context,
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(authViewModel.errorMessage ?? 'Error'),
            backgroundColor: AppColors.warningColor,
          ),
        );
      }
    }
  }

  void _handleGoogleLogin() async {
    FocusScope.of(context).unfocus();
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isGoogleLoading = true);
    final result = await authViewModel.signInWithGoogleLogin(context);
    if (!mounted) return;
    setState(() => _isGoogleLoading = false);

    if (result == 'HOME') {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (authViewModel.errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage!),
          backgroundColor: AppColors.warningColor,
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            const LoginBackground(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const LoginHeader(), // Widget de cabecera
                    LoginForm(
                      formKey: _formKey,
                      emailController: emailController,
                      passwordController: passwordController,
                      isLoading:
                          Provider.of<AuthViewModel>(context).isLoading &&
                          !_isGoogleLoading,
                      onLoginPressed: _handleLogin,
                      onForgotPasswordPressed: _showForgotPasswordDialog,
                    ),
                    const SizedBox(height: 24),
                    SocialLoginSection(
                      isGoogleLoading: _isGoogleLoading,
                      onGooglePressed: _handleGoogleLogin,
                    ),
                    const SizedBox(height: 30),
                    const RegistrationLink(), // Widget de enlace de registro
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
