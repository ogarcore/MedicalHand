import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/view/widgets/custom_modal.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/utils/input_formatters.dart';
import '../../../app/core/utils/validators.dart'; // Asegúrate de importar tus validadores
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/registration_progress_indicator.dart';
import '../../widgets/custom_dropdown.dart';
import 'registration_step3_screen.dart';
import '../../../view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import '../welcome/welcome_screen.dart';

// PASO 1: Convertido a StatefulWidget
class RegistrationStep2Screen extends StatefulWidget {
  const RegistrationStep2Screen({super.key});

  @override
  State<RegistrationStep2Screen> createState() =>
      _RegistrationStep2ScreenState();
}

class _RegistrationStep2ScreenState extends State<RegistrationStep2Screen> {
  // PASO 2: Añadida la clave del formulario
  final _formKey = GlobalKey<FormState>();

  Future<void> _onWillPop() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    await showDialog(
      context: context,
      builder: (context) => CustomModal(
        icon: HugeIcons.strokeRoundedAlert01,
        title: '¿Estás seguro?',
        content: const Text(
          'Si sales ahora, perderás todo el progreso del registro.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        actions: [
          ModalButton(
            text: 'Cancelar',
            onPressed: () => Navigator.of(context).pop(),
          ),
          ModalButton(
            text: 'Salir',
            isWarning: true, // Usa tu estilo de botón de advertencia.
            onPressed: () async {
              // La lógica de salida es exactamente la misma que antes.
              await authViewModel.cancelGoogleRegistration();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final Size size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _onWillPop();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  // PASO 3: Envuelto en un widget Form
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed:
                                  _onWillPop, // Llama a la misma función de salida
                              icon: const Icon(
                                Icons.arrow_back,
                                color: AppColors.textColor,
                                size: 26.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Datos Personales",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const RegistrationProgressIndicator(currentStep: 2),
                        const SizedBox(height: 32),
                        const Text(
                          'Ahora, cuéntanos sobre ti',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          controller: authViewModel.nameController,
                          labelText: 'Nombres',
                          hintText: 'Ingresa tus nombres',
                          icon: Icons.person,
                          // Aplicando validador
                          validator: (value) =>
                              AppValidators.validateGenericEmpty(
                                value,
                                'Nombres',
                              ),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: authViewModel.lastNameController,
                          labelText: 'Apellidos',
                          hintText: 'Ingresa tus apellidos',
                          icon: Icons.person_outline,
                          // Aplicando validador
                          validator: (value) =>
                              AppValidators.validateGenericEmpty(
                                value,
                                'Apellidos',
                              ),
                        ),
                        const SizedBox(height: 10),
                        Consumer<AuthViewModel>(
                          builder: (context, viewModel, child) {
                            return AppStyledDropdown(
                              value: viewModel.selectedSex,
                              items: const ['Masculino', 'Femenino', 'Otro'],
                              hintText: 'Selecciona tu sexo',
                              prefixIcon: Icons.favorite_outline,
                              onChanged: (String? newValue) {
                                viewModel.updateSelectedSex(newValue);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: authViewModel.idController,
                          labelText: 'Cédula de Identidad',
                          hintText: '001-010101-0001A',
                          icon: Icons.badge_outlined,
                          keyboardType: TextInputType.visiblePassword,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(16),
                            CedulaInputFormatter(),
                          ],
                          // Aplicando validador
                          validator: AppValidators.validateCedula,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: authViewModel.birthDateController,
                          labelText: 'Fecha de Nacimiento',
                          hintText: 'DD/MM/AAAA',
                          icon: Icons.calendar_today_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                            DateInputFormatter(),
                          ],
                          // Aplicando validador
                          validator: AppValidators.validateBirthDate,
                        ),
                        const SizedBox(height: 50),
                        PrimaryButton(
                          text: 'Siguiente',
                          onPressed: () {
                            if (authViewModel.selectedSex == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Por favor, selecciona tu sexo.',
                                  ),
                                  backgroundColor: AppColors.warningColor,
                                ),
                              );
                              return;
                            }
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegistrationStep3Screen(),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 20),
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
