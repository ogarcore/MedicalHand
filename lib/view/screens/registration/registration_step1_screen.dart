import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/utils/validators.dart';
import '../../../view_model/auth_view_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/registration_progress_indicator.dart';
import 'registration_step2_screen.dart';

// Convertido a StatefulWidget para manejar el estado del formulario correctamente.
class RegistrationStep1Screen extends StatefulWidget {
  const RegistrationStep1Screen({super.key});

  @override
  State<RegistrationStep1Screen> createState() =>
      _RegistrationStep1ScreenState();
}

class _RegistrationStep1ScreenState extends State<RegistrationStep1Screen> {
  // La clave del formulario se inicializa aquí para que persista entre reconstrucciones.
  final _formKey = GlobalKey<FormState>();

  void _clearFieldsAndNavigateBack() {
    // Obtenemos el viewModel para acceder a los controladores
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // 1. Limpia los controladores de texto.
    authViewModel.emailController.clear();
    authViewModel.passwordController.clear();
    authViewModel.confirmPasswordController.clear();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final Size size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _clearFieldsAndNavigateBack();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              // --- Tu código de decoración de fondo (sin cambios) ---
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
                right: -size.width * 0.2,
                child: Container(
                  width: size.width * 0.8,
                  height: size.width * 0.8,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withAlpha(15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withAlpha(50),
                        blurRadius: 40,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -size.height * 0.2,
                left: -size.width * 0.2,
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

              // --- Fin del código de decoración ---
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: _clearFieldsAndNavigateBack,
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: AppColors.textColor,
                                    size: 26.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Crear cuenta",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const RegistrationProgressIndicator(currentStep: 1),
                            const SizedBox(height: 32),
                            const Text(
                              'Primero, tus datos de acceso',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 24),
                            CustomTextField(
                              controller: authViewModel.emailController,
                              labelText: 'Correo Electrónico',
                              hintText: 'Ingresa tu correo',
                              icon: Icons.alternate_email,
                              keyboardType: TextInputType.emailAddress,
                              validator: AppValidators.validateEmail,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: authViewModel.passwordController,
                              labelText: 'Crea una contraseña',
                              hintText: 'Mínimo 8 caracteres',
                              isPassword: true,
                              icon: Icons.lock_outline,
                              validator: AppValidators.validatePassword,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller:
                                  authViewModel.confirmPasswordController,
                              labelText: 'Confirmar contraseña',
                              hintText: 'Repite tu contraseña',
                              isPassword: true,
                              icon: Icons.lock_outline,
                              validator: (value) =>
                                  AppValidators.validateConfirmPassword(
                                    authViewModel.passwordController.text,
                                    value,
                                  ),
                            ),
                            const SizedBox(height: 32),
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
                                    'O regístrate con',
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
                            Consumer<AuthViewModel>(
                              builder: (context, viewModel, child) {
                                return Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: 280,
                                    child: OutlinedButton.icon(
                                      onPressed: viewModel.isLoading
                                          ? null
                                          : () async {
                                              final scaffoldMessenger =
                                                  ScaffoldMessenger.of(context);
                                              final navigator = Navigator.of(
                                                context,
                                              );
                                              final result = await viewModel
                                                  .signInWithGoogleFlow();
                                              if (!mounted) return;
                                              if (result == null) {
                                                scaffoldMessenger.showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      viewModel.errorMessage ??
                                                          'Ocurrió un error.',
                                                    ),
                                                    backgroundColor: AppColors.warningColor,
                                                  ),
                                                );
                                                return;
                                              }
                                              if (result == 'EXIST') {
                                                scaffoldMessenger.showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: AppColors
                                                        .accentColor
                                                        .withAlpha(200),
                                                    content: const Text(
                                                      'Esta cuenta de Google ya está registrada. Por favor, inicia sesión.',
                                                    ),
                                                  ),
                                                );
                                              }
                                              if (result == 'REGISTER_STEP_2') {
                                                navigator.pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const RegistrationStep2Screen(),
                                                  ),
                                                );
                                              }
                                            },
                                      icon: viewModel.isLoading
                                          ? Container(
                                              width: 24,
                                              height: 24,
                                              padding: const EdgeInsets.all(
                                                2.0,
                                              ),
                                              child:
                                                  const CircularProgressIndicator(
                                                    color:
                                                        AppColors.primaryColor,
                                                    strokeWidth: 3,
                                                  ),
                                            )
                                          : Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Image.asset(
                                                'assets/images/google_icon.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                      label: const Text(
                                        'Registrarse con Google',
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
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        side: BorderSide.none,
                                        backgroundColor: Colors.grey.shade200,
                                        foregroundColor: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 50),
                            PrimaryButton(
                              text: 'Siguiente',
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegistrationStep2Screen(),
                                    ),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
