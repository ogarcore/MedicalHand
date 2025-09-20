// lib/view/screens/profile/edit_medical_info_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
import 'package:p_hn25/view/widgets/primary_button.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class EditMedicalInfoScreen extends StatefulWidget {
  final UserModel user;
  const EditMedicalInfoScreen({super.key, required this.user});

  @override
  State<EditMedicalInfoScreen> createState() => _EditMedicalInfoScreenState();
}

class _EditMedicalInfoScreenState extends State<EditMedicalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bloodTypeController;
  late TextEditingController _allergiesController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bloodTypeController = TextEditingController(
      text: widget.user.medicalInfo?['bloodType'] ?? '',
    );
    _allergiesController = TextEditingController(
      text: widget.user.medicalInfo?['knownAllergies'] ?? '',
    );
  }

  @override
  void dispose() {
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedData = {
      'medicalInfo.bloodType': _bloodTypeController.text.trim(),
      'medicalInfo.knownAllergies': _allergiesController.text.trim(),
    };

    final viewModel = Provider.of<UserViewModel>(context, listen: false);
    final success = await viewModel.updateUserProfile(updatedData);

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(width: 12),
            Expanded(
              child: Text(
                success
                    ? 'Información actualizada con éxito.'
                    : 'Error al actualizar.',
              ),
            ),
          ],
        ),
        backgroundColor: success
            ? AppColors.secondaryColor.withAlpha(220)
            : AppColors.warningColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.only(bottom: 10, left: 20, right: 20),
        duration: Duration(seconds: 3),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Cerrar el teclado cuando se toque fuera de los campos de texto
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Información Médica',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: AppColors.accentColor, // Cambiado a accentColor
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Tarjeta de información médica
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accentColor.withAlpha(
                          30,
                        ), // Cambiado a accentColor
                        AppColors.accentColor.withAlpha(
                          15,
                        ), // Cambiado a accentColor
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.accentColor.withAlpha(
                            40,
                          ), // Cambiado a accentColor
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          HugeIcons.strokeRoundedCovidInfo,
                          size: 40,
                          color: AppColors.accentColor.withAlpha(
                            220,
                          ), // Cambiado a accentColor
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Editar Datos Médicos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Esta información es crucial en caso de emergencias médicas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Campo Tipo de Sangre
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CustomTextField(
                    controller: _bloodTypeController,
                    labelText: 'Tipo de Sangre',
                    hintText: 'Ej: O+, AB-, B+',
                    keyboardType: TextInputType.text,
                    icon: Icons.bloodtype_outlined,
                    validator: AppValidators.validateOptionalBloodType,
                  ),
                ),
                const SizedBox(height: 24),

                // Campo Alergias
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CustomTextField(
                    controller: _allergiesController,
                    labelText: 'Alergias Conocidas',
                    hintText: 'Ej: Penicilina, Maní, etc.',
                    icon: Icons.warning_amber_rounded,
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 40),

                // Botón de Guardar
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentColor, // Cambiado a accentColor
                        AppColors.accentColor.withAlpha(
                          220,
                        ), // Cambiado a accentColor
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentColor.withAlpha(
                          120,
                        ), // Cambiado a accentColor
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: PrimaryButton(
                    text: 'Guardar Cambios',
                    onPressed: _handleSave,
                    isLoading: _isLoading,
                    backgroundColor: AppColors.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
