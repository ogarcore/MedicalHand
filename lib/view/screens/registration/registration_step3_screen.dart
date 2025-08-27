import 'package:flutter/material.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/utils/validators.dart'; // Importamos los validadores
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/registration_progress_indicator.dart';
import 'registration_step4_screen.dart';
import '../../../app/core/utils/input_formatters.dart';
import '../../../view_model/auth_view_model.dart';
import 'package:provider/provider.dart';

// PASO 1: Convertido a StatefulWidget
class RegistrationStep3Screen extends StatefulWidget {
  const RegistrationStep3Screen({super.key});

  @override
  State<RegistrationStep3Screen> createState() =>
      _RegistrationStep3ScreenState();
}

class _RegistrationStep3ScreenState extends State<RegistrationStep3Screen> {
  // PASO 2: Añadida la clave del formulario
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // ... (Tu código de decoración de fondo no cambia)
            Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor.withAlpha(30),
                          AppColors.backgroundColor
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter))),
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
                              spreadRadius: 20)
                        ]))),
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
                              spreadRadius: 30)
                        ]))),

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
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back,
                                color: AppColors.textColor, size: 26.5),
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
                        controller: authViewModel.phoneController,
                        labelText: 'Número de Teléfono',
                        hintText: '0000-0000',
                        icon: Icons.phone_outlined,
                        inputFormatters: [PhoneInputFormatter()],
                        keyboardType: TextInputType.phone,
                        // Aplicando validador obligatorio
                        validator: AppValidators.validatePhone,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: authViewModel.addressController,
                        labelText: 'Dirección de Domicilio',
                        hintText: 'Ingresa su dirección',
                        icon: Icons.home_outlined,
                        // Aplicando validador genérico obligatorio
                        validator: (value) => AppValidators.validateGenericEmpty(value, 'La dirección'),
                      ),
                      const SizedBox(height: 30),
                      const Row(
                        children: [
                          Text(
                            'Contacto de Emergencia',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '(Opcional)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Color.fromARGB(255, 107, 107, 107),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: authViewModel.emergencyNameController,
                        labelText: 'Nombre del Contacto',
                        hintText: 'Ingrese el nombre del contacto',
                        icon: Icons.person_outline,
                        // No necesita validador, se revisará en el botón
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: authViewModel.emergencyPhoneController,
                        labelText: 'Número de Teléfono',
                        hintText: '0000-0000',
                        icon: Icons.phone_outlined,
                        inputFormatters: [PhoneInputFormatter()],
                        keyboardType: TextInputType.phone,
                        // Aplicando validador opcional
                        validator: AppValidators.validateOptionalPhone,
                      ),
                      const SizedBox(height: 50),
                      PrimaryButton(
                        text: 'Siguiente',
                        // PASO 4: Lógica de validación en el botón
                        onPressed: () {
                          // Ocultamos el teclado
                          FocusScope.of(context).unfocus();

                          // Primero, validamos el formulario
                          if (_formKey.currentState!.validate()) {
                            // Si el formulario es válido, hacemos una revisión extra
                            final emergencyName = authViewModel.emergencyNameController.text;
                            final emergencyPhone = authViewModel.emergencyPhoneController.text;

                            // Si se ingresó un nombre de emergencia pero no un teléfono
                            if (emergencyName.isNotEmpty && emergencyPhone.isEmpty) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Por favor, ingresa el teléfono del contacto de emergencia.'),
                                  backgroundColor: AppColors.warningColor,
                                ),
                              );
                              return; // Detiene
                            }

                            // Si se ingresó un teléfono de emergencia pero no un nombre
                            if (emergencyPhone.isNotEmpty && emergencyName.isEmpty) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Por favor, ingresa el nombre del contacto de emergencia.'),
                                  backgroundColor: AppColors.warningColor,
                                ),
                              );
                              return; // Detiene
                            }

                            // Si todo está correcto, navegamos
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegistrationStep4Screen(),
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
    );
  }
}