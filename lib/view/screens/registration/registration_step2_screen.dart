import 'package:flutter/material.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/registration_progress_indicator.dart';
import 'registration_step3_screen.dart';

class RegistrationStep2Screen extends StatelessWidget {
  const RegistrationStep2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController idController = TextEditingController();
    final TextEditingController birthDateController = TextEditingController();
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
                    controller: nameController,
                    labelText: 'Nombres',
                    hintText: 'Ej: John',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: lastNameController,
                    labelText: 'Apellidos',
                    hintText: 'Ej: Doe',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: idController,
                    labelText: 'Cédula de Identidad',
                    hintText: '001-010101-0001A',
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: birthDateController,
                    labelText: 'Fecha de Nacimiento',
                    hintText: 'DD/MM/AAAA',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 50),

                  PrimaryButton(
                    text: 'Siguiente',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistrationStep3Screen(),
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
