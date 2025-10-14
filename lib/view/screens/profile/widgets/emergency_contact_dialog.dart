import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class EmergencyContactDialog extends StatefulWidget {
  final UserModel user;

  const EmergencyContactDialog({super.key, required this.user});

  @override
  State<EmergencyContactDialog> createState() => _EmergencyContactDialogState();
}

class _EmergencyContactDialogState extends State<EmergencyContactDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final contact = widget.user.medicalInfo?['emergencyContact'] as Map?;
    _nameController = TextEditingController(text: contact?['name'] ?? '');
    _phoneController = TextEditingController(text: contact?['phone'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userViewModel = context.read<UserViewModel>();
    final success = await userViewModel.updateEmergencyContact(
      _nameController.text.trim(),
      _phoneController.text.trim(),
    );

    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(); // Cierra el diálogo

    if (success) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('contacto_de_emergencia_guardado'.tr())),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Error al guardar el contacto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 30, offset: const Offset(0, 10)),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primaryColor, Color.lerp(primaryColor, Colors.white, 0.3)!]),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: BorderRadius.circular(10)),
                      child: Icon(HugeIcons.strokeRoundedCall, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('contacto_de_emergencia'.tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('en_caso_de_emergencia_contactaremos_a_esta_persona'.tr(), style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(200))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration('Nombre del contacto', 'Ej: María González'),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'El nombre es requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: _inputDecoration('Número de teléfono', 'Ej: +1234567890'),
                        keyboardType: TextInputType.phone,
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'El teléfono es requerido' : null,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              child: Text('cancelar'.tr(), style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveContact,
                              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              child: Text('guardar'.tr(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.all(16),
    );
  }
}