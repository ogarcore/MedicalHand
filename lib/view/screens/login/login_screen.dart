import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/core/utils/validators.dart';
import '../../../view_model/auth_view_model.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/custom_text_field.dart';
import '../home/home_screen.dart';
import '../registration/registration_step1_screen.dart';
import '../../../app/core/constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isGoogleLoading = false; // ← loader exclusivo de Google

  // ----- LÓGICA PARA RECUPERAR CONTRASEÑA -----
  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recuperar Contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ingresa el correo de tu cuenta para enviarte un enlace de recuperación.',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: resetEmailController,
                labelText: 'Correo Electrónico',
                hintText: 'Ingresa un correo de recuperación',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (resetEmailController.text.isEmpty) return;

                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                final error = await authViewModel.sendPasswordResetLink(
                  resetEmailController.text.trim(),
                );

                if (!mounted) return;
                navigator.pop();

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
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final authViewModel = Provider.of<AuthViewModel>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true, // 👈 importante
        body: Stack(
          children: [
            // --- Fondo decorativo ---
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withAlpha(30),
                    AppColors.backgroundColor,
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
                  color: AppColors.primaryColor.withAlpha(15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withAlpha(60),
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
                  color: AppColors.primaryColor.withAlpha(10),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withAlpha(80),
                      blurRadius: 50,
                      spreadRadius: 30,
                    ),
                  ],
                ),
              ),
            ),

            // --- Contenido con scroll ---
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                color: AppColors.primaryColor.withAlpha(50),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.supervised_user_circle,
                            size: 60,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        '¡Bienvenido/a!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Accede a tu cuenta para continuar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // --- Inputs ---
                      CustomTextField(
                        controller: emailController,
                        labelText: 'Correo electrónico',
                        hintText: 'Ingrese su correo',
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.email_outlined,
                        validator: AppValidators.validateEmail,
                      ),
                      const SizedBox(height: 25),
                      CustomTextField(
                        controller: passwordController,
                        labelText: 'Contraseña',
                        hintText: 'Ingresa su contraseña',
                        isPassword: true,
                        icon: Icons.lock_outline,
                        validator: (value) =>
                            AppValidators.validateGenericEmpty(
                              value,
                              'La contraseña',
                            ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // --- Botón login ---
                      PrimaryButton(
                        text: 'Iniciar Sesión',
                        isLoading: !_isGoogleLoading && authViewModel.isLoading,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);

                            final success = await authViewModel.signInUser(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );

                            if (!mounted) return;

                            if (success) {
                              navigator.pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            } else {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    authViewModel.errorMessage ?? 'Error',
                                  ),
                                  backgroundColor: AppColors.warningColor,
                                ),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // --- Google login ---
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey[400],
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Text(
                              'O ingresa con',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[400],
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 280,
                          child: _isGoogleLoading
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14.5, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.primaryColor),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Cargando...',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : OutlinedButton.icon(
                                  onPressed: () async {
                                    final navigator = Navigator.of(context);
                                    final messenger =
                                        ScaffoldMessenger.of(context);

                                    setState(() {
                                      _isGoogleLoading = true;
                                    });

                                    final result = await authViewModel
                                        .signInWithGoogleLogin();

                                    if (!mounted) return;

                                    setState(() {
                                      _isGoogleLoading = false;
                                    });

                                    if (result == 'HOME') {
                                      navigator.pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const HomeScreen(),
                                        ),
                                      );
                                    } else if (authViewModel.errorMessage !=
                                        null) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            authViewModel.errorMessage!,
                                          ),
                                          backgroundColor:
                                              AppColors.warningColor,
                                        ),
                                      );
                                    }
                                  },
                                  icon: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Image.asset(
                                      'assets/images/google_icon.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  label: const Text(
                                    'Iniciar sesión con Google',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14.5,
                                      horizontal: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    side: BorderSide.none,
                                    backgroundColor: Colors.grey.shade200,
                                    foregroundColor: AppColors.textColor,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- Registro ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿No tienes una cuenta?',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 15,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegistrationStep1Screen(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryColor,
                            ),
                            child: Text(
                              'Regístrate',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
