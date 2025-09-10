// lib/view/screens/family/add_family_member_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/utils/input_formatters.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view/widgets/custom_dropdown.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
import 'package:p_hn25/view/widgets/primary_button.dart';
import 'package:p_hn25/view_model/family_view_model.dart';
import 'package:provider/provider.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  const AddFamilyMemberScreen({super.key});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores para todos los campos del formulario
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _idController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _allergiesController = TextEditingController();

  String? _selectedKinship;

  final List<String> _kinshipOptions = [
    'Madre',
    'Padre',
    'Hijo/a',
    'Cónyuge',
    'Abuelo/a',
    'Otro',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _idController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    // Oculta el teclado
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Convertimos el texto de la fecha a un objeto DateTime
    final dateParts = _birthDateController.text.split('/');
    final birthDate = DateTime(
      int.parse(dateParts[2]),
      int.parse(dateParts[1]),
      int.parse(dateParts[0]),
    );

    final newMember = UserModel(
      uid: '',
      email: '',
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      idNumber: _idController.text.trim(),
      dateOfBirth: Timestamp.fromDate(birthDate),
      sex: 'No especificado',
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      medicalInfo: {
        'kinship': _selectedKinship,
        'bloodType': _bloodTypeController.text.trim(),
        'knownAllergies': _allergiesController.text.trim(),
        'chronicDiseases': [],
      },
      isTutor: false,
    );

    final viewModel = Provider.of<FamilyViewModel>(context, listen: false);
    final success = await viewModel.addFamilyMember(newMember);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        backgroundColor: success
            ? AppColors.successColor.withOpacity(0.9)
            : AppColors.warningColor.withOpacity(0.9),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                success
                    ? '¡Familiar añadido con éxito!'
                    : 'Error al añadir familiar.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (success) {
      Navigator.pop(context);
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 👇 al tocar fuera, se quita el foco (cierra teclado)
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
                Container(
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
                            child: Icon(
                              HugeIcons.strokeRoundedUserWarning01,
                              size: 18,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Información Esencial',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppStyledDropdown(
                        value: _selectedKinship,
                        items: _kinshipOptions,
                        onChanged: (newValue) {
                          setState(() => _selectedKinship = newValue);
                        },
                        hintText: 'Parentesco',
                        prefixIcon: HugeIcons.strokeRoundedUserGroup,
                        validator: (value) =>
                            value == null ? 'Selecciona un parentesco' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _firstNameController,
                        labelText: 'Nombres',
                        hintText: 'Nombres del familiar',
                        icon: HugeIcons.strokeRoundedUser,
                        validator: (value) =>
                            AppValidators.validateGenericEmpty(
                              value,
                              'El nombre',
                            ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _lastNameController,
                        labelText: 'Apellidos',
                        hintText: 'Apellidos del familiar',
                        icon: HugeIcons.strokeRoundedUser,
                        validator: (value) =>
                            AppValidators.validateGenericEmpty(
                              value,
                              'El apellido',
                            ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _idController,
                        labelText: 'Cédula',
                        hintText: '001-123456-1234A',
                        icon: HugeIcons.strokeRoundedId,
                        keyboardType: TextInputType.visiblePassword,
                        inputFormatters: [CedulaInputFormatter()],
                        validator: AppValidators.validateCedula,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _birthDateController,
                        labelText: 'Fecha de Nacimiento',
                        hintText: 'DD/MM/AAAA',
                        icon: HugeIcons.strokeRoundedCalendar01,
                        keyboardType: TextInputType.number,
                        inputFormatters: [DateInputFormatter()],
                        validator: AppValidators.validateBirthDate,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Sección de Información de Contacto
                Container(
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
                            child: Icon(
                              HugeIcons.strokeRoundedContactBook,
                              size: 18,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Información de Contacto (Opcional)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _phoneController,
                        labelText: 'Teléfono',
                        hintText: '0000-0000',
                        icon: HugeIcons.strokeRoundedTelephone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [PhoneInputFormatter()],
                        validator: AppValidators.validateOptionalPhone,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _addressController,
                        labelText: 'Dirección',
                        hintText: 'Dirección de domicilio',
                        icon: HugeIcons.strokeRoundedLocation01,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Sección de Información Médica
                Container(
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
                            child: Icon(
                              HugeIcons.strokeRoundedHealth,
                              size: 18,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Información Médica (Opcional)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _bloodTypeController,
                        labelText: 'Tipo de Sangre',
                        hintText: 'Ej: O+',
                        icon: HugeIcons.strokeRoundedBloodBag,
                        validator: AppValidators.validateOptionalBloodType,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _allergiesController,
                        labelText: 'Alergias Conocidas',
                        hintText: 'Ej: Penicilina',
                        icon: HugeIcons.strokeRoundedMedicalMask,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                PrimaryButton(
                  text: 'Guardar Familiar',
                  onPressed: _onSave,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
