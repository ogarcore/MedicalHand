import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/utils/input_formatters.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/data/network/image_picker_service.dart';
import 'package:p_hn25/data/network/permission_service.dart';
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
  final PermissionService _permissionService = PermissionService(); // Instancia del servicio

  // CAMBIO CLAVE 1: La función ahora es asíncrona y maneja el permiso.
  Future<void> _handleImagePick(Function(XFile?) setImageCallback) async {
    // Primero, solicitamos el permiso de cámara de forma segura.
    final hasPermission = await _permissionService.handleCameraPermission(context);

    // Si no se otorgó el permiso, no continuamos.
    if (!hasPermission || !mounted) return;

    // Si el permiso fue otorgado, procedemos a abrir la cámara.
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
    // Este widget no necesita cambios internos.
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryColor(context).withAlpha(20)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryColor(context)
              : Colors.grey.shade300,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primaryColor(context)
                        : AppColors.primaryColor(context).withAlpha(20),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? Colors.white
                        : AppColors.primaryColor(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryColor(context)
                          : AppColors.textColor(context),
                    ),
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  color: isSelected
                      ? AppColors.successColor(context)
                      : Colors.grey.shade400,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final familyViewModel = context.watch<FamilyViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: const Text(
          'Verificación de Identidad',
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
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor(context).withAlpha(15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryColor(context).withAlpha(40),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor(context).withAlpha(30),
                      ),
                      child: Icon(
                        HugeIcons.strokeRoundedShield01,
                        size: 24,
                        color: AppColors.primaryColor(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isMinor
                                ? 'Identificación del Menor'
                                : 'Identificación del Familiar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textColor(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.isMinor
                                ? 'Completa la información de identificación del menor'
                                : 'Verifica la identidad de tu familiar',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textLightColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: familyViewModel.idController,
                labelText:
                    widget.isMinor ? 'Partida de Nacimiento' : 'Cédula',
                hintText:
                    widget.isMinor ? 'N° de documento' : '001-123456-1234A',
                keyboardType: TextInputType.visiblePassword,
                icon: HugeIcons.strokeRoundedId,
                inputFormatters:
                    widget.isMinor ? [] : [CedulaInputFormatter()],
                validator: widget.isMinor
                    ? (val) => AppValidators.validateGenericEmpty(
                          val,
                          'El documento',
                        )
                    : AppValidators.validateCedula,
              ),
              const SizedBox(height: 24),
              Text(
                'Documento de Identificación',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isMinor
                    ? 'Toma una foto de la partida de nacimiento'
                    : 'Toma fotos de ambos lados de la cédula',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textLightColor(context),
                ),
              ),
              const SizedBox(height: 16),
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor(context),
                      AppColors.primaryColor(context).withAlpha(220),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor(context).withAlpha(100),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: PrimaryButton(
                  text: 'Finalizar y Guardar',
                  isLoading: familyViewModel.isLoading,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (familyViewModel.idFrontImage == null ||
                          (!widget.isMinor && familyViewModel.idBackImage == null)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Por favor, sube las fotos requeridas.',
                            ),
                            backgroundColor: AppColors.warningColor(context),
                          ),
                        );
                        return;
                      }
                      bool success = await familyViewModel.saveFamilyMember(
                        context,
                      );
                      if (success && context.mounted) {
                        int count = 0;
                        Navigator.of(context).popUntil((_) => count++ >= 2);
                      }
                    }
                  },
                  backgroundColor: Colors.transparent,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}