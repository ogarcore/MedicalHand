import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p_hn25/data/network/image_picker_service.dart';
import 'package:p_hn25/data/network/permission_service.dart';
import 'package:p_hn25/view/screens/registration/registration_step4_screen.dart';
import 'package:p_hn25/view/widgets/gradient_background.dart';
import 'package:p_hn25/view/widgets/primary_button.dart';
import 'package:p_hn25/view/widgets/registration_progress_indicator.dart';
import 'package:provider/provider.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/utils/input_formatters.dart';
import '../../../app/core/utils/validators.dart';
import '../../../view_model/auth_view_model.dart';
import '../../widgets/custom_text_field.dart';

class RegistrationStep3Screen extends StatefulWidget {
  const RegistrationStep3Screen({super.key});

  @override
  State<RegistrationStep3Screen> createState() =>
      _RegistrationStep3ScreenState();
}

class _RegistrationStep3ScreenState extends State<RegistrationStep3Screen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePickerService _imagePickerService = ImagePickerService();
  final PermissionService _permissionService = PermissionService(); // Instancia del servicio

  // CAMBIO CLAVE 1: La función ahora es asíncrona y maneja el permiso.
  Future<void> _handleImagePick(
      void Function(XFile?) setImageCallback) async {
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
    required String description,
    required VoidCallback onPressed,
    bool isSelected = false,
  }) {
    // Este widget no necesita cambios internos.
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor(context).withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryColor(context),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  color: isSelected
                      ? AppColors.successColor(context)
                      : Colors.grey.shade400,
                  size: 24,
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
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: GradientBackground(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.arrow_back,
                                color: AppColors.textColor(context),
                                size: 26.5,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'verificacin_de_identidad'.tr(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const RegistrationProgressIndicator(
                          currentStep: 3,
                          totalSteps: 5,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'proteccin_de_tu_informacin'.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textLightColor(context),
                              height: 1.4,
                              fontFamily: 'Poppins',
                            ),
                            children: [
                              TextSpan(
                                text: 'para_garantizar_la_seguridad_de_tu_expediente'.tr(),
                              ),
                              TextSpan(
                                text: 'verificamos_tu_identidad'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor(context),
                                ),
                              ),
                              TextSpan(
                                text: 'para_proteger_tus_datos_mdicos'.tr(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          controller: authViewModel.idController,
                          labelText: 'cdula_de_identidad'.tr(),
                          hintText: '001-010101-0001A',
                          icon: HugeIcons.strokeRoundedId,
                          keyboardType: TextInputType.visiblePassword,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(16),
                            CedulaInputFormatter(),
                          ],
                          validator: AppValidators.validateCedula,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'documentacin_requerida'.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor(context),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'toma_fotos_ntidas_de_ambos_lados_de_tu_cdula'.tr(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildVerificationButton(
                          icon: HugeIcons.strokeRoundedCamera01,
                          text: 'frente_de_la_cdula'.tr(),
                          description: 'Datos visibles y legibles',
                          onPressed: () =>
                              _handleImagePick(authViewModel.setIdFrontImage),
                          isSelected: authViewModel.idFrontImage != null,
                        ),
                        _buildVerificationButton(
                          icon: HugeIcons.strokeRoundedCamera01,
                          text: 'reverso_de_la_cdula'.tr(),
                          description: 'Asegúrate que se vea bien',
                          onPressed: () =>
                              _handleImagePick(authViewModel.setIdBackImage),
                          isSelected: authViewModel.idBackImage != null,
                        ),
                        const SizedBox(height: 30),
                        PrimaryButton(
                          text: 'continuar'.tr(),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            if (_formKey.currentState!.validate()) {
                              if (authViewModel.idFrontImage == null ||
                                  authViewModel.idBackImage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'por_favor_sube_las_imgenes_requeridas'.tr(),
                                    ),
                                    backgroundColor: AppColors.warningColor(
                                      context,
                                    ),
                                  ),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegistrationStep4Screen(),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}