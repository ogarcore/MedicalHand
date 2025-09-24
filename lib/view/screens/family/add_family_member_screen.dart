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

  // Función auxiliar para calcular la edad de forma segura.
  int? _calculateAge(String dateText) {
    if (AppValidators.validateBirthDate(dateText) != null) {
      return null; // Si la fecha no es válida, no hay edad.
    }
    try {
      final dateParts = dateText.split('/');
      final birthDate = DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
      );
      // Usamos ~/ para obtener un entero de la división.
      return DateTime.now().difference(birthDate).inDays ~/ 365;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final familyViewModel = context.watch<FamilyViewModel>();

    // --- LÓGICA DE EDAD ---
    // Calculamos la edad en cada rebuild.
    final age = _calculateAge(familyViewModel.birthDateController.text);
    // La validación del teléfono depende de si es menor de 14 años.
    final bool isPhoneOptional = age != null && age < 14;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor(context),
        appBar: AppBar(
          title: const Text(
            'Añadir Nuevo Familiar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          backgroundColor: AppColors.backgroundColor(context),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sección de Información Esencial (sin cambios)
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
                      // Este setState es clave para que la pantalla se redibuje y la lógica de la edad funcione.
                      onChanged: (value) => setState(() {}),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- SECCIÓN DE CONTACTO MODIFICADA ---
                // Ahora es siempre visible y con la nueva lógica de validación.
                _buildSectionContainer(
                  title: 'Información de Contacto',
                  icon: HugeIcons.strokeRoundedContactBook,
                  children: [
                    CustomTextField(
                      controller: familyViewModel.phoneController,
                      // El label cambia dinámicamente.
                      labelText: isPhoneOptional
                          ? 'Teléfono (Opcional)'
                          : 'Teléfono',
                      hintText: '0000-0000',
                      icon: HugeIcons.strokeRoundedTelephone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [PhoneInputFormatter()],
                      // El validador cambia según la edad.
                      validator: isPhoneOptional
                          ? AppValidators.validateOptionalPhone
                          : AppValidators.validatePhone,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: familyViewModel.addressController,
                      // El campo ya no es opcional.
                      labelText: 'Dirección',
                      hintText: 'Dirección de domicilio',
                      icon: HugeIcons.strokeRoundedLocation01,
                      // Se añade el validador para que sea obligatorio.
                      validator: (value) => AppValidators.validateGenericEmpty(
                        value,
                        'La dirección',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Sección de Información Médica (sin cambios)
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
                      // Se reutiliza la lógica de la edad para pasarla a la siguiente pantalla.
                      final currentAge =
                          _calculateAge(
                            familyViewModel.birthDateController.text,
                          ) ??
                          0;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: familyViewModel,
                            child: FamilyVerificationScreen(
                              isMinor: currentAge < 18,
                            ),
                          ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withAlpha(40), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor(context).withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.primaryColor(context),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor(context),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
