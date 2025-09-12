// lib/view/screens/family/family_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/utils/input_formatters.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/data/network/image_picker_service.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
import 'package:p_hn25/view/widgets/primary_button.dart';
import 'package:p_hn25/view_model/family_view_model.dart';
import 'package:provider/provider.dart';

class FamilyVerificationScreen extends StatefulWidget {
  final bool isMinor;
  const FamilyVerificationScreen({super.key, required this.isMinor});

  @override
  State<FamilyVerificationScreen> createState() =>
      _FamilyVerificationScreenState();
}

class _FamilyVerificationScreenState extends State<FamilyVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePickerService _imagePickerService = ImagePickerService();

  Future<void> _handleImagePick(Function(XFile?) setImageCallback) async {
    final file = await _imagePickerService.pickAndCompressImage();
    if (file != null) {
      setImageCallback(file);
    }
  }

  Widget _buildVerificationButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    bool isSelected = false,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.primaryColor),
      label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          Icon(
            isSelected
                ? Icons.check_circle_rounded
                : Icons.chevron_right_rounded,
            color: isSelected ? AppColors.successColor : Colors.grey.shade400,
          ),
        ],
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos watch para que los botones se actualicen al seleccionar imagen
    final familyViewModel = context.watch<FamilyViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Verificación de Identidad'),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.isMinor
                    ? 'Identificación del Menor'
                    : 'Identificación del Familiar',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isMinor
                    ? 'Por favor, ingresa el número de partida de nacimiento y adjunta una foto.'
                    : 'Por favor, ingresa el número de cédula y adjunta fotos de ambos lados.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: familyViewModel.idController,
                labelText: widget.isMinor ? 'Partida de Nacimiento' : 'Cédula',
                hintText: widget.isMinor
                    ? 'N° de documento'
                    : '001-123456-1234A',
                icon: HugeIcons.strokeRoundedId,
                inputFormatters: widget.isMinor ? [] : [CedulaInputFormatter()],
                validator: widget.isMinor
                    ? (val) => AppValidators.validateGenericEmpty(
                        val,
                        'El documento',
                      )
                    : AppValidators.validateCedula,
              ),
              const SizedBox(height: 20),
              if (widget.isMinor)
                _buildVerificationButton(
                  icon: HugeIcons.strokeRoundedCamera01,
                  text: 'Tomar foto de la Partida',
                  onPressed: () =>
                      _handleImagePick(familyViewModel.setIdFrontImage),
                  isSelected: familyViewModel.idFrontImage != null,
                )
              else ...[
                _buildVerificationButton(
                  icon: HugeIcons.strokeRoundedCamera01,
                  text: 'Tomar foto del Frente',
                  onPressed: () =>
                      _handleImagePick(familyViewModel.setIdFrontImage),
                  isSelected: familyViewModel.idFrontImage != null,
                ),
                const SizedBox(height: 12),
                _buildVerificationButton(
                  icon: HugeIcons.strokeRoundedCamera01,
                  text: 'Tomar foto del Reverso',
                  onPressed: () =>
                      _handleImagePick(familyViewModel.setIdBackImage),
                  isSelected: familyViewModel.idBackImage != null,
                ),
              ],
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Finalizar y Guardar',
                isLoading: familyViewModel.isLoading,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (familyViewModel.idFrontImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Por favor, sube la foto del documento.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    bool success = await familyViewModel.saveFamilyMember(
                      context,
                    );
                    if (success && context.mounted) {
                      // Regresa a la pantalla de la lista de familiares
                      int count = 0;
                      Navigator.of(context).popUntil((_) => count++ >= 2);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
