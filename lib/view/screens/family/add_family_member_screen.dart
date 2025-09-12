// lib/view/screens/family/add_family_member_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/utils/input_formatters.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/view/widgets/custom_dropdown.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
import 'package:p_hn25/view/widgets/primary_button.dart';
import 'package:p_hn25/view_model/family_view_model.dart';
import 'package:provider/provider.dart';
import 'family_verification_screen.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  const AddFamilyMemberScreen({super.key});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final familyViewModel = context.watch<FamilyViewModel>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Añadir Nuevo Familiar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sección de Información Esencial
                _buildSectionContainer(
                  title: 'Información Esencial',
                  icon: HugeIcons.strokeRoundedUserWarning01,
                  children: [
                    AppStyledDropdown(
                      value: familyViewModel.selectedKinship,
                      items: const [
                        'Madre',
                        'Padre',
                        'Hijo/a',
                        'Cónyuge',
                        'Abuelo/a',
                        'Otro',
                      ],
                      onChanged: (newValue) =>
                          familyViewModel.updateSelectedKinship(newValue),
                      hintText: 'Parentesco',
                      prefixIcon: HugeIcons.strokeRoundedUserGroup,
                      validator: (value) =>
                          value == null ? 'Selecciona un parentesco' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: familyViewModel.firstNameController,
                      labelText: 'Nombres',
                      hintText: 'Nombres del familiar',
                      icon: HugeIcons.strokeRoundedUser,
                      validator: (value) => AppValidators.validateGenericEmpty(
                        value,
                        'El nombre',
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: familyViewModel.lastNameController,
                      labelText: 'Apellidos',
                      hintText: 'Apellidos del familiar',
                      icon: HugeIcons.strokeRoundedUser,
                      validator: (value) => AppValidators.validateGenericEmpty(
                        value,
                        'El apellido',
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: familyViewModel.birthDateController,
                      labelText: 'Fecha de Nacimiento',
                      hintText: 'DD/MM/AAAA',
                      icon: HugeIcons.strokeRoundedCalendar01,
                      keyboardType: TextInputType.number,
                      inputFormatters: [DateInputFormatter()],
                      validator: AppValidators.validateBirthDate,
                      onChanged: (value) => setState(() {}),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Sección de Información de Contacto (Dinámica)
                if (familyViewModel.birthDateController.text.isNotEmpty &&
                    AppValidators.validateBirthDate(
                          familyViewModel.birthDateController.text,
                        ) ==
                        null)
                  Builder(
                    builder: (context) {
                      final dateParts = familyViewModel.birthDateController.text
                          .split('/');
                      final birthDate = DateTime(
                        int.parse(dateParts[2]),
                        int.parse(dateParts[1]),
                        int.parse(dateParts[0]),
                      );
                      final age =
                          DateTime.now().difference(birthDate).inDays / 365;
                      final isMinor = age < 18;

                      return _buildSectionContainer(
                        title: 'Información de Contacto',
                        icon: HugeIcons.strokeRoundedContactBook,
                        children: [
                          CustomTextField(
                            controller: familyViewModel.phoneController,
                            labelText: 'Teléfono',
                            hintText: '0000-0000',
                            icon: HugeIcons.strokeRoundedTelephone,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [PhoneInputFormatter()],
                            validator: isMinor
                                ? AppValidators.validateOptionalPhone
                                : AppValidators.validatePhone,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: familyViewModel.addressController,
                            labelText: 'Dirección (Opcional)',
                            hintText: 'Dirección de domicilio',
                            icon: HugeIcons.strokeRoundedLocation01,
                          ),
                        ],
                      );
                    },
                  ),

                const SizedBox(height: 20),

                _buildSectionContainer(
                  title: 'Información Médica (Opcional)',
                  icon: HugeIcons.strokeRoundedHealth,
                  children: [
                    CustomTextField(
                      controller: familyViewModel.bloodTypeController,
                      labelText: 'Tipo de Sangre',
                      hintText: 'Ej: O+',
                      icon: HugeIcons.strokeRoundedBloodBag,
                      validator: AppValidators.validateOptionalBloodType,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: familyViewModel.allergiesController,
                      labelText: 'Alergias Conocidas',
                      hintText: 'Ej: Penicilina',
                      icon: HugeIcons.strokeRoundedMedicalMask,
                      maxLines: 3,
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                PrimaryButton(
                  text: 'Siguiente Paso',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final dateParts = familyViewModel.birthDateController.text
                          .split('/');
                      final birthDate = DateTime(
                        int.parse(dateParts[2]),
                        int.parse(dateParts[1]),
                        int.parse(dateParts[0]),
                      );
                      final age =
                          DateTime.now().difference(birthDate).inDays / 365;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // ----- INICIO DEL CAMBIO -----
                          // Usamos ChangeNotifierProvider.value para pasar un ViewModel existente
                          builder: (_) => ChangeNotifierProvider.value(
                            value: familyViewModel,
                            child: FamilyVerificationScreen(isMinor: age < 18),
                          ),
                          // ----- FIN DEL CAMBIO -----
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
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: AppColors.primaryColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
