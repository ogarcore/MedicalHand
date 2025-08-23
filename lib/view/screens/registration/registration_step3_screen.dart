import 'package:flutter/material.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/registration_progress_indicator.dart';
import 'registration_step4_screen.dart';

class RegistrationStep3Screen extends StatelessWidget {
  const RegistrationStep3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor.withAlpha(30), AppColors.backgroundColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Círculos decorativos
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

          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Encabezado personalizado
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: AppColors.textColor, size: 26.5),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Datos de Contacto",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const RegistrationProgressIndicator(currentStep: 3),
                  const SizedBox(height: 32),

                  const Text(
                    '¿Cómo podemos contactarte?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  CustomTextField(
                    controller: phoneController,
                    labelText: 'Número de Teléfono',
                    hintText: 'Ej: 8888-8888',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: addressController,
                    labelText: 'Dirección de Domicilio',
                    hintText: 'Ej: Managua, Nicaragua',
                    icon: Icons.home_outlined,
                  ),
                  const SizedBox(height: 50),

                  PrimaryButton(
                    text: 'Siguiente',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistrationStep4Screen(),
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
    );
  }
}
