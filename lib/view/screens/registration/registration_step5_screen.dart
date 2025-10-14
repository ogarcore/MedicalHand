import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:p_hn25/view/screens/splash/splash_screen.dart';
import 'package:p_hn25/view/widgets/gradient_background.dart';
import 'package:provider/provider.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/utils/validators.dart'; // Importamos los validadores
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/registration_progress_indicator.dart';
import '../../widgets/custom_list.dart';
import '../../../view_model/auth_view_model.dart';
import 'verification_screen.dart';

// PASO 1: Convertido a StatefulWidget
class RegistrationStep5Screen extends StatefulWidget {
  const RegistrationStep5Screen({super.key});

  @override
  State<RegistrationStep5Screen> createState() =>
      _RegistrationStep5ScreenState();
}

class _RegistrationStep5ScreenState extends State<RegistrationStep5Screen> {
  // PASO 2: Añadida la clave del formulario
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: GradientBackground(
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  // PASO 3: Envuelto en un widget Form
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: AppColors.textColor(context),
                                  size: 26.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'informacin_mdica'.tr(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const RegistrationProgressIndicator(currentStep: 5),
                          const SizedBox(height: 32),
                          Text(
                            'por_ltimo_algunos_datos_bsicos'.tr(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor(context),
                            ),
                          ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            controller: authViewModel.bloodTypeController,
                            labelText: 'tipo_de_sangre'.tr(),
                            hintText: 'Ej: O+, AB-, B+',
                            keyboardType: TextInputType.text,
                            icon: Icons.bloodtype_outlined,
                            validator: AppValidators.validateOptionalBloodType,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: authViewModel.allergiesController,
                            labelText: 'alergias_conocidas'.tr(),
                            hintText: 'ej_penicilina_man_etc'.tr(),
                            icon: Icons.warning_amber_rounded,
                            // No necesita validador por ser texto libre
                          ),
                          const SizedBox(height: 20),
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
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor(
                                context,
                              ).withAlpha(60),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaryColor(
                                  context,
                                ).withAlpha(80),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: AppColors.primaryColor(context),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'si_no_tienes_conocimientos_de_estos_datos_puedes_finalizar_e'.tr(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textColor(
                                        context,
                                      ).withAlpha(200),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          PrimaryButton(
                            text: 'finalizar_registro'.tr(),
                            isLoading: authViewModel.isLoading,
                            // PASO 4: Lógica de validación en el botón
                            onPressed: () async {
                              // Validamos el formulario antes de finalizar
                              if (_formKey.currentState!.validate()) {
                                final result = await authViewModel
                                    .finalizeRegistration(context);

                                if (!context.mounted) return;

                                if (result == 'VERIFY') {
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
                                } else if (result == 'SPLASH') {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SplashScreen(),
                                    ),
                                    (route) => false,
                                  );
                                  authViewModel.clearControllers();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        authViewModel.errorMessage ??
                                            'Ocurrió un error.',
                                      ),
                                      backgroundColor: AppColors.warningColor(
                                        context,
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
