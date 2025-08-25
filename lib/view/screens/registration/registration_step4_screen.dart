import 'package:flutter/material.dart';
import 'package:p_hn25/view/screens/splash/splash_screen.dart';
import 'package:provider/provider.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/registration_progress_indicator.dart';
import '../../widgets/custom_list.dart';
import '../../../view_model/auth_view_model.dart';
import 'verification_screen.dart';

class RegistrationStep4Screen extends StatelessWidget {
  const RegistrationStep4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos Consumer para que la UI se reconstruya cuando cambie el estado
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final Size size = MediaQuery.of(context).size;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: Stack(
              children: [
                // ... (tu código de fondo y círculos decorativos permanece igual)
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

                SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ... (tu encabezado y progress indicator permanecen igual)
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: AppColors.textColor,
                                  size: 26.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Información Médica",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const RegistrationProgressIndicator(currentStep: 4),
                          const SizedBox(height: 32),
                          const Text(
                            'Por último, algunos datos básicos',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ----- CAMBIO APLICADO AQUÍ -----
                          CustomTextField(
                            controller: authViewModel.bloodTypeController,
                            labelText: 'Tipo de Sangre',
                            hintText: 'Ingrese su tipo de sangre',
                            icon: Icons.bloodtype_outlined,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: authViewModel.allergiesController,
                            labelText: 'Alergias Conocidas',
                            hintText: 'Ingrese sus alergias',
                            icon: Icons.warning_amber_rounded,
                          ),
                          const SizedBox(height: 20),

                          // ----- CAMBIO APLICADO AQUÍ -----
                          ChronicDiseasesList(
                            selectedDiseases: authViewModel.selectedDiseases,
                            onDiseaseSelected: (disease, selected) {
                              authViewModel.updateSelectedDiseases(
                                disease,
                                selected ?? false,
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // ... (tu texto informativo permanece igual)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withAlpha(60),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaryColor.withAlpha(80),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: AppColors.primaryColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Si no tienes conocimientos de estos datos, puedes finalizar el registro y actualizarlos después en tu perfil.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textColor.withAlpha(200),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (authViewModel.isLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            PrimaryButton(
                              text: 'Finalizar Registro',
                              onPressed: () async {
                                final result = await authViewModel
                                    .finalizeRegistration();
                                if (result == 'VERIFY' && context.mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VerificationScreen(
                                        email:
                                            authViewModel.emailController.text,
                                      ),
                                    ),
                                    (route) => false,
                                  );
                                  authViewModel.clearControllers();
                                } else if (result == 'SPLASH' &&
                                    context.mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SplashScreen(),
                                    ),
                                    (route) => false,
                                  );
                                  authViewModel.clearControllers();
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        authViewModel.errorMessage ??
                                            'Ocurrió un error.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
