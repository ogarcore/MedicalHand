import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/view/screens/registration/registration_step4_screen.dart';
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

  // Diseño compacto para los botones de captura
  Widget _buildVerificationButton({
    required IconData icon,
    required String text,
    required String description,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
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
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
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
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withAlpha(30),
                    AppColors.backgroundColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: -size.height * 0.25,
              right: -size.width * 0.2,
              child: Container(
                width: size.width * 0.8,
                height: size.width * 0.8,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withAlpha(15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withAlpha(50),
                      blurRadius: 40,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -size.height * 0.2,
              left: -size.width * 0.2,
              child: Container(
                width: size.width * 0.65,
                height: size.width * 0.65,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withAlpha(10),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withAlpha(80),
                      blurRadius: 50,
                      spreadRadius: 30,
                    ),
                  ],
                ),
              ),
            ),

            SafeArea(
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
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.textColor,
                              size: 26.5,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Verificación de Identidad",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const RegistrationProgressIndicator(currentStep: 3),
                      const SizedBox(height: 32),
                      const Text(
                        'Protección de tu información',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textLightColor,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(
                              text:
                                  'Para garantizar la seguridad de tu expediente, ',
                            ),
                            TextSpan(
                              text: 'verificamos tu identidad',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                            const TextSpan(
                              text: ' para proteger tus datos médicos.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: authViewModel.idController,
                        labelText: 'Cédula de Identidad',
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
                      const Text(
                        'Documentación requerida',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Toma fotos nítidas de ambos lados de tu cédula',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildVerificationButton(
                        icon: HugeIcons.strokeRoundedCamera01,
                        text: 'Frente de la Cédula',
                        description: 'Datos visibles y legibles',
                        onPressed: () {},
                      ),
                      _buildVerificationButton(
                        icon: HugeIcons.strokeRoundedCamera01,
                        text: 'Reverso de la Cédula',
                        description: 'Datos visibles y legibles',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 30),
                      PrimaryButton(
                        text: 'Continuar',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
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
          ],
        ),
      ),
    );
  }
}
