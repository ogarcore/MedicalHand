// lib/view/screens/profile/edit_medical_info_screen.dart
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
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
        content: Text(
          success
              ? 'Información actualizada con éxito.'
              : 'Error al actualizar.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Editar Información Médica'),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: const Text('Guardar'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _bloodTypeController,
                labelText: 'Tipo de Sangre',
                hintText: 'Ej: O+',
                icon: Icons.bloodtype_outlined,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _allergiesController,
                labelText: 'Alergias Conocidas',
                hintText: 'Ej: Penicilina, Mariscos',
                icon: Icons.warning_amber_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Guardar Cambios',
                onPressed: _handleSave,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
