// lib/view/screens/profile/edit_personal_info_screen.dart
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
import 'package:p_hn25/view/widgets/primary_button.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class EditPersonalInfoScreen extends StatefulWidget {
  final UserModel user;
  const EditPersonalInfoScreen({super.key, required this.user});

  @override
  State<EditPersonalInfoScreen> createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _addressController = TextEditingController(text: widget.user.address);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedData = {
      'contactInfo.phoneNumber': _phoneController.text.trim(),
      'contactInfo.address': _addressController.text.trim(),
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
            ? AppColors.secondaryColor(context).withAlpha(220)
            : AppColors.warningColor(context),
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
        backgroundColor: AppColors.backgroundColor(context),
        appBar: AppBar(
          title: const Text(
            'Información Personal',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: AppColors.accentColor(context),
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
                // Tarjeta de información personal
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accentColor(context).withAlpha(30),
                        AppColors.accentColor(context).withAlpha(15),
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
                          color: AppColors.accentColor(context).withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 40,
                          color: AppColors.accentColor(context).withAlpha(220),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Editar Datos Personales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mantén tu información de contacto actualizada',
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

                // Campo Teléfono
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
                    controller: _phoneController,
                    labelText: 'Teléfono',
                    hintText: 'Tu número de teléfono',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(height: 24),

                // Campo Dirección
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
                    controller: _addressController,
                    labelText: 'Dirección',
                    hintText: 'Tu dirección de domicilio',
                    icon: Icons.location_on_outlined,
                  ),
                ),
                const SizedBox(height: 40),

                // Botón de Guardar
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentColor(context),
                        AppColors.accentColor(context).withAlpha(220),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentColor(context).withAlpha(120),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: PrimaryButton(
                    text: 'Guardar Cambios',
                    onPressed: _handleSave,
                    isLoading: _isLoading,
                    backgroundColor: AppColors.accentColor(context),
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
