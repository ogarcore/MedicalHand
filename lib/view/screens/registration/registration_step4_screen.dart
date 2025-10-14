import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:p_hn25/view/widgets/gradient_background.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/utils/validators.dart'; // Importamos los validadores
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/registration_progress_indicator.dart';
import 'registration_step5_screen.dart';
import '../../../app/core/utils/input_formatters.dart';
import '../../../view_model/auth_view_model.dart';
import 'package:provider/provider.dart';

// PASO 1: Convertido a StatefulWidget
class RegistrationStep4Screen extends StatefulWidget {
  const RegistrationStep4Screen({super.key});

  @override
  State<RegistrationStep4Screen> createState() =>
      _RegistrationStep4ScreenState();
}

class _RegistrationStep4ScreenState extends State<RegistrationStep4Screen> {
  // PASO 2: Añadida la clave del formulario
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: GradientBackground(
          child: SafeArea(
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
                          icon: Icon(
                            Icons.arrow_back,
                            color: AppColors.textColor(context),
                            size: 26.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'datos_de_contacto'.tr(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const RegistrationProgressIndicator(currentStep: 4),
                    const SizedBox(height: 32),
                    Text(
                      'como_podemos_contactarte'.tr(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: authViewModel.phoneController,
                      labelText: 'nmero_de_telfono'.tr(),
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
                      labelText: 'direccin_de_domicilio'.tr(),
                      hintText: 'ingresa_su_direccin'.tr(),
                      icon: Icons.home_outlined,
                      minLines: 1,
                      maxLines: 3,
                      validator: (value) => AppValidators.validateGenericEmpty(
                        value,
                        'La dirección',
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Text(
                          'contacto_de_emergencia'.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor(context),
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
                      labelText: 'nombre_del_contacto'.tr(),
                      hintText: 'ingrese_el_nombre_del_contacto'.tr(),
                      icon: Icons.person_outline,
                      // No necesita validador, se revisará en el botón
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: authViewModel.emergencyPhoneController,
                      labelText: 'nmero_de_telfono'.tr(),
                      hintText: '0000-0000',
                      icon: Icons.phone_outlined,
                      inputFormatters: [PhoneInputFormatter()],
                      keyboardType: TextInputType.phone,
                      // Aplicando validador opcional
                      validator: AppValidators.validateOptionalPhone,
                    ),
                    const SizedBox(height: 50),
                    PrimaryButton(
                      text: 'siguiente'.tr(),
                      // PASO 4: Lógica de validación en el botón
                      onPressed: () {
                        // Ocultamos el teclado
                        FocusScope.of(context).unfocus();

                        // Primero, validamos el formulario
                        if (_formKey.currentState!.validate()) {
                          // Si el formulario es válido, hacemos una revisión extra
                          final emergencyName =
                              authViewModel.emergencyNameController.text;
                          final emergencyPhone =
                              authViewModel.emergencyPhoneController.text;

                          // Si se ingresó un nombre de emergencia pero no un teléfono
                          if (emergencyName.isNotEmpty &&
                              emergencyPhone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'por_favor_ingresa_el_telfono_del_contacto_de_emergencia'.tr(),
                                ),
                                backgroundColor: AppColors.warningColor(
                                  context,
                                ),
                              ),
                            );
                            return; // Detiene
                          }

                          // Si se ingresó un teléfono de emergencia pero no un nombre
                          if (emergencyPhone.isNotEmpty &&
                              emergencyName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'por_favor_ingresa_el_nombre_del_contacto_de_emergencia'.tr(),
                                ),
                                backgroundColor: AppColors.warningColor(
                                  context,
                                ),
                              ),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RegistrationStep5Screen(),
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
        ),
      ),
    );
  }
}
