import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:p_hn25/view/widgets/gradient_background.dart';
import 'package:provider/provider.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../app/core/utils/validators.dart';
import '../../../view_model/auth_view_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/registration_progress_indicator.dart';
import 'registration_step2_screen.dart';

class RegistrationStep1Screen extends StatefulWidget {
  const RegistrationStep1Screen({super.key});

  @override
  State<RegistrationStep1Screen> createState() =>
      _RegistrationStep1ScreenState();
}

class _RegistrationStep1ScreenState extends State<RegistrationStep1Screen> {
  final _formKey = GlobalKey<FormState>();

  bool _isCheckingEmail = false; // loader solo para 'siguiente'.tr()
  bool _isGoogleLoading = false; // loader exclusivo de Google

  void _clearFieldsAndNavigateBack() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    authViewModel.emailController.clear();
    authViewModel.passwordController.clear();
    authViewModel.confirmPasswordController.clear();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _clearFieldsAndNavigateBack();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: GradientBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: _clearFieldsAndNavigateBack,
                            icon: Icon(
                              Icons.arrow_back,
                              color: AppColors.textColor(context),
                              size: 26.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'crear_cuenta'.tr(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const RegistrationProgressIndicator(currentStep: 1),
                      const SizedBox(height: 32),
                      Text(
                        'primero_tus_datos_de_acceso'.tr(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor(context),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: authViewModel.emailController,
                        labelText: 'correo_electrnico'.tr(),
                        hintText: 'ingresa_tu_correo'.tr(),
                        icon: Icons.alternate_email,
                        keyboardType: TextInputType.emailAddress,
                        validator: AppValidators.validateEmail,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: authViewModel.passwordController,
                        labelText: 'crea_una_contrasea'.tr(),
                        hintText: 'mnimo_8_caracteres'.tr(),
                        isPassword: true,
                        icon: Icons.lock_outline,
                        keyboardType: TextInputType.visiblePassword,
                        validator: AppValidators.validatePassword,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: authViewModel.confirmPasswordController,
                        labelText: 'confirmar_contrasea'.tr(),
                        hintText: 'repite_tu_contrasea'.tr(),
                        keyboardType: TextInputType.visiblePassword,
                        isPassword: true,
                        icon: Icons.lock_outline,
                        validator: (value) =>
                            AppValidators.validateConfirmPassword(
                              authViewModel.passwordController.text,
                              value,
                            ),
                      ),
                      const SizedBox(height: 32),
                      Consumer<AuthViewModel>(
                        builder: (context, viewModel, child) {
                          return PrimaryButton(
                            text: 'siguiente'.tr(),
                            isLoading: _isCheckingEmail,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                FocusScope.of(context).unfocus();

                                setState(() {
                                  _isCheckingEmail = true;
                                });

                                // Guardamos referencias ANTES del await
                                final scaffoldMessenger = ScaffoldMessenger.of(
                                  context,
                                );
                                final navigator = Navigator.of(context);

                                final emailExists = await viewModel
                                    .checkEmailExists();

                                if (!mounted) return;

                                setState(() {
                                  _isCheckingEmail = false;
                                });

                                if (emailExists) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        viewModel.errorMessage ??
                                            'Error desconocido.',
                                      ),
                                      backgroundColor: AppColors.warningColor(
                                        context,
                                      ),
                                    ),
                                  );
                                } else {
                                  navigator.push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegistrationStep2Screen(),
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey[400],
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Text(
                              'o_regstrate_con'.tr(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[400],
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Consumer<AuthViewModel>(
                        builder: (context, viewModel, child) {
                          return Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 280,
                              child: _isGoogleLoading
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14.5,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    AppColors.primaryColor(
                                                      context,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'cargando'.tr(),
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textColor(
                                                context,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : OutlinedButton.icon(
                                      onPressed: () async {
                                        // Guardamos referencias ANTES del await
                                        final scaffoldMessenger =
                                            ScaffoldMessenger.of(context);
                                        final navigator = Navigator.of(context);

                                        setState(() {
                                          _isGoogleLoading = true;
                                        });

                                        final result = await viewModel
                                            .signInWithGoogleFlow();

                                        if (!mounted) return;

                                        setState(() {
                                          _isGoogleLoading = false;
                                        });

                                        if (result == null) {
                                          scaffoldMessenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                viewModel.errorMessage ??
                                                    'Ocurrió un error.',
                                              ),
                                              backgroundColor:
                                                  AppColors.warningColor(
                                                    context,
                                                  ),
                                            ),
                                          );
                                          return;
                                        }
                                        if (result == 'EXIST') {
                                          scaffoldMessenger.showSnackBar(
                                            SnackBar(
                                              backgroundColor:
                                                  AppColors.accentColor(
                                                    context,
                                                  ).withAlpha(200),
                                              content: Text(
                                                'esta_cuenta_ya_est_registrada_por_favor_inicia_sesin'.tr(),
                                              ),
                                            ),
                                          );
                                        }
                                        if (result == 'REGISTER_STEP_2') {
                                          navigator.pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const RegistrationStep2Screen(),
                                            ),
                                          );
                                        }
                                      },
                                      icon: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Image.asset(
                                          'assets/images/google_icon.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      label: Text(
                                        'registrarse_con_google'.tr(),
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textColor(context),
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14.5,
                                          horizontal: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        side: BorderSide.none,
                                        backgroundColor: Colors.grey.shade200,
                                        foregroundColor: AppColors.textColor(
                                          context,
                                        ),
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
