import 'package:easy_localization/easy_localization.dart';
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
  final PermissionService _permissionService = PermissionService();

  Future<void> _handleImagePick(Function(XFile?) setImageCallback) async {
    final hasPermission = await _permissionService.handleCameraPermission(context);
    if (!hasPermission || !mounted) return;

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

    // ✅ CAMBIO: Se envuelve el Scaffold con un GestureDetector.
    return GestureDetector(
      // Al tocar fuera de un campo de texto, se quita el foco y se cierra el teclado.
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor(context),
        appBar: AppBar(
          title: Text(
            'verificacin_de_identidad'.tr(),
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
                                  : 'identificacin_del_familiar'.tr(),
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
                                  : 'verifica_la_identidad_de_tu_familiar'.tr(),
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
                  'documento_de_identificacin'.tr(),
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
                      : 'toma_fotos_de_ambos_lados_de_la_cdula'.tr(),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textLightColor(context),
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.isMinor)
                  _buildVerificationButton(
                    icon: HugeIcons.strokeRoundedCamera01,
                    text: 'tomar_foto_de_la_partida'.tr(),
                    onPressed: () =>
                        _handleImagePick(familyViewModel.setIdFrontImage),
                    isSelected: familyViewModel.idFrontImage != null,
                  )
                else ...[
                  _buildVerificationButton(
                    icon: HugeIcons.strokeRoundedCamera01,
                    text: 'tomar_foto_del_frente'.tr(),
                    onPressed: () =>
                        _handleImagePick(familyViewModel.setIdFrontImage),
                    isSelected: familyViewModel.idFrontImage != null,
                  ),
                  const SizedBox(height: 12),
                  _buildVerificationButton(
                    icon: HugeIcons.strokeRoundedCamera01,
                    text: 'tomar_foto_del_reverso'.tr(),
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
                    text: 'finalizar_y_guardar'.tr(),
                    isLoading: familyViewModel.isLoading,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (familyViewModel.idFrontImage == null ||
                            (!widget.isMinor && familyViewModel.idBackImage == null)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'por_favor_sube_las_fotos_requeridas'.tr(),
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
      ),
    );
  }
}