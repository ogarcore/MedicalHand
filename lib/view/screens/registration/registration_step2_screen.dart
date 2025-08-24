import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- AÑADE ESTA IMPORTACIÓN
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/utils/input_formatters.dart'; // <-- AÑADE ESTA IMPORTACIÓN
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/registration_progress_indicator.dart';
import '../../widgets/custom_dropdown.dart';
import 'registration_step3_screen.dart';

class RegistrationStep2Screen extends StatefulWidget {
  const RegistrationStep2Screen({super.key});

  @override
  State<RegistrationStep2Screen> createState() =>
      _RegistrationStep2ScreenState();
}

class _RegistrationStep2ScreenState extends State<RegistrationStep2Screen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  String? selectedSex;

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    idController.dispose();
    birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ... (tu encabezado personalizado permanece igual)
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
                      hintText: 'Ingresa tus nombres',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: lastNameController,
                      labelText: 'Apellidos',
                      hintText: 'Ingresa tus apellidos',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 10),

                    AppStyledDropdown(
                      value: selectedSex,
                      items: const ['Masculino', 'Femenino', 'Otro'],
                      hintText: 'Selecciona tu sexo',
                      prefixIcon: Icons.favorite_outline,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSex = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: idController,
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
                      controller: birthDateController,
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
    );
  }
}