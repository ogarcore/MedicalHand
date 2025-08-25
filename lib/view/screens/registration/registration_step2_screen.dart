import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/utils/input_formatters.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/registration_progress_indicator.dart';
import '../../widgets/custom_dropdown.dart';
import 'registration_step3_screen.dart';
import '../../../view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import '../welcome/welcome_screen.dart'; // Importa la pantalla de Welcome

class RegistrationStep2Screen extends StatelessWidget {
  const RegistrationStep2Screen({super.key});

  Future<bool> _onWillPop(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    bool? exit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Estás seguro?'),
        content: const Text(
          'Si sales ahora, perderás todo el progreso del registro.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // No salir
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
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
            child: const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return exit ?? false; // Si el usuario cierra el diálogo, no salimos
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final Size size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _onWillPop(context);
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          // ----- CAMBIO APLICADO AQUÍ -----
                          // El botón de retroceso ahora también llama al diálogo
                          IconButton(
                            onPressed: () async {
                              bool canPop = await _onWillPop(context);
                              if (canPop && context.mounted) {
                                Navigator.pop(context);
                              }
                            },
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

                      // ... (the rest of your UI code remains the same)
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
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: authViewModel.lastNameController,
                        labelText: 'Apellidos',
                        hintText: 'Ingresa tus apellidos',
                        icon: Icons.person_outline,
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
                        hintText: 'Ingresa su cédula',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.visiblePassword,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(16),
                          CedulaInputFormatter(),
                        ],
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
                      ),
                      const SizedBox(height: 50),
                      PrimaryButton(
                        text: 'Siguiente',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RegistrationStep3Screen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
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
