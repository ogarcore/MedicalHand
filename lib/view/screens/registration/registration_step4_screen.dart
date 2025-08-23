import 'package:flutter/material.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/registration_progress_indicator.dart';
import '../welcome/welcome_screen.dart';

class RegistrationStep4Screen extends StatelessWidget {
  const RegistrationStep4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController bloodTypeController = TextEditingController();
    final TextEditingController allergiesController = TextEditingController();
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withAlpha(30),
                  AppColors.backgroundColor
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Círculo decorativo arriba
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

          // Círculo decorativo abajo
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

          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Encabezado con botón back
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.textColor, size: 26.5),
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

                  CustomTextField(
                    controller: bloodTypeController,
                    labelText: 'Tipo de Sangre',
                    hintText: 'Ej: O+',
                    icon: Icons.bloodtype_outlined,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: allergiesController,
                    labelText: 'Alergias Conocidas',
                    hintText: 'Ej: Penicilina, Mariscos',
                    icon: Icons.warning_amber_rounded,
                  ),
                  const SizedBox(height: 50),

                  PrimaryButton(
                    text: 'Finalizar Registro',
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen(),
                        ),
                        (Route<dynamic> route) => false,
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
    );
  }
}
