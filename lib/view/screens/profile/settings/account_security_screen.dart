import 'package:easy_localization/easy_localization.dart';
// lib/view/screens/profile/settings/account_security_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/view/screens/splash/splash_screen.dart';
import 'package:p_hn25/view/widgets/custom_modal.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:p_hn25/view_model/user_view_model.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  final TextEditingController _confirmController = TextEditingController();
  bool _isDeleteButtonEnabled = false;
  bool _isDeleting = false;

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Scaffold(
        backgroundColor: Colors.transparent,
        body: const _ChangePasswordDialog(),
      ),
    );
  }

  // Inicia el flujo completo de eliminación
  void _startDeleteAccountProcess() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    bool reauthenticated = false;
    final isGoogleProvider =
        user.providerData.any((info) => info.providerId == 'google.com');

    setState(() => _isDeleting = true);

    if (isGoogleProvider) {
      reauthenticated = await _reauthenticateWithGoogle();
    } else {
      final password = await _promptForPassword(context);
      if (password != null && password.isNotEmpty) {
        reauthenticated =
            await Provider.of<UserViewModel>(context, listen: false)
                .reauthenticate(user.email!, password);
      }
    }

    if (!reauthenticated) {
      setState(() => _isDeleting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('autenticacin_fallida_no_se_elimin_la_cuenta'.tr()),
            backgroundColor: AppColors.warningColor(context),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final success =
        await Provider.of<UserViewModel>(context, listen: false).deleteAccount();

    setState(() => _isDeleting = false);

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (Route<dynamic> route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ocurrió un error al eliminar la cuenta.'),
          backgroundColor: AppColors.warningColor(context),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Función para reautenticar con Google
  Future<bool> _reauthenticateWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return false;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.currentUser
          ?.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      print("Error en reautenticación con Google: $e");
      return false;
    }
  }

  // Modal para pedir la contraseña al usuario de correo
  Future<String?> _promptForPassword(BuildContext context) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('confirmar_identidad'.tr()),
          content: Form(
            key: formKey,
            child: CustomTextField(
              controller: passwordController,
              labelText: 'contrasea'.tr(),
              hintText: 'ingresa_tu_contrasea_actual'.tr(),
              icon: HugeIcons.strokeRoundedLockPassword,
              obscureText: true,
              validator: (value) =>
                  AppValidators.validateGenericEmpty(value, 'La contraseña'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text('cancelar'.tr()),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(passwordController.text);
                }
              },
              child: Text('confirmar'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountFlow(BuildContext context) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomModal(
          icon: HugeIcons.strokeRoundedSad01,
          title: 'lamentamos_que_te_vayas'.tr(),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'tu_opinin_es_muy_importante_para_nosotros'.tr(),
                  style: TextStyle(
                    color: AppColors.textLightColor(context),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  labelText: 'motivo_de_la_eliminacin'.tr(),
                  icon: HugeIcons.strokeRoundedAlertDiamond,
                  controller: reasonController,
                  hintText: 'explcanos_por_qu_deseas_cerrar_la_cuenta'.tr(),
                  maxLines: 3,
                  validator: AppValidators.validateRescheduleReason,
                ),
              ],
            ),
          ),
          actions: [
            ModalButton(
              text: 'cancelar'.tr(),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ModalButton(
              text: 'siguiente'.tr(),
              isPrimary: true,
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop();
                  _showFinalConfirmationDialog(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFinalConfirmationDialog(BuildContext context) {
    _confirmController.clear();
    setState(() => _isDeleteButtonEnabled = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: CustomModal(
                icon: HugeIcons.strokeRoundedAlertDiamond,
                title: '¿Estás seguro?',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'esta_accin_es_permanente_todos_tus_datos_sern_eliminados_def'.tr(),
                      style: TextStyle(
                        color: AppColors.textLightColor(context),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'para_confirmar_escribe_la_palabra'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      labelText: 'escribelo_aqu'.tr(),
                      icon: HugeIcons.strokeRoundedAlertDiamond,
                      controller: _confirmController,
                      hintText: 'eliminar'.tr(),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
                        TextInputFormatter.withFunction(
                          (oldValue, newValue) => newValue.copyWith(
                            text: newValue.text.toUpperCase(),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          _isDeleteButtonEnabled = (value == 'eliminar'.tr());
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  ModalButton(
                    text: 'cancelar'.tr(),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                  ModalButton(
                    text: 's_eliminar'.tr(),
                    isWarning: true,
                    // ✅ FIX: Se corrige el tipo de la función onPressed.
                    // En lugar de `null`, se pasa una función vacía si está deshabilitado.
                    onPressed: _isDeleteButtonEnabled
                        ? () {
                            Navigator.of(dialogContext).pop();
                            _startDeleteAccountProcess();
                          }
                        : () {},
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    bool showChangePassword = false;
    if (user != null) {
      showChangePassword = user.providerData.any(
        (userInfo) => userInfo.providerId == 'password',
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor(context),
        appBar: AppBar(
          title: Text('cuenta_y_seguridad'.tr()),
          backgroundColor: AppColors.backgroundColor(context),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Column(
                      children: [
                        if (showChangePassword) ...[
                          _SettingsOptionRow(
                            title: 'cambiar_contrasea'.tr(),
                            onTap: () => _showChangePasswordDialog(context),
                          ),
                          Divider(
                              height: 1,
                              color: Colors.grey.shade200,
                              indent: 16),
                        ],
                        _SettingsOptionRow(
                          title: 'eliminar_cuenta'.tr(),
                          onTap: () => _showDeleteAccountFlow(context),
                          textColor: AppColors.warningColor(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isDeleting)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsOptionRow extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _SettingsOptionRow({
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.textColor(context),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey.shade400,
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => __ChangePasswordDialogState();
}

class __ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordObscured = true;
  bool _isNewPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final viewModel = Provider.of<UserViewModel>(context, listen: false);
    final success = await viewModel.changePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('contrasea_actualizada_con_xito'.tr()),
          backgroundColor: AppColors.secondaryColor(context),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: La contraseña actual es incorrecta.'),
          backgroundColor: AppColors.warningColor(context),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: CustomModal(
        isLoading: _isLoading,
        icon: HugeIcons.strokeRoundedShield01,
        title: 'cambiar_contrasea'.tr(),
        content: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'para_proteger_tu_cuenta_ingresa_tu_contrasea_actual_antes_de'.tr(),
                style: TextStyle(color: AppColors.textLightColor(context)),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _currentPasswordController,
                labelText: 'contrasea_actual'.tr(),
                hintText: 'ingresa_tu_contrasea_actual'.tr(),
                icon: HugeIcons.strokeRoundedCirclePassword,
                obscureText: _isCurrentPasswordObscured,
                validator: (value) => AppValidators.validateGenericEmpty(
                    value, 'La contraseña actual'),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isCurrentPasswordObscured
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => setState(() =>
                      _isCurrentPasswordObscured = !_isCurrentPasswordObscured),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _newPasswordController,
                labelText: 'nueva_contrasea'.tr(),
                hintText: 'mnimo_8_caracteres'.tr(),
                icon: HugeIcons.strokeRoundedLockPassword,
                obscureText: _isNewPasswordObscured,
                validator: AppValidators.validatePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isNewPasswordObscured
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => setState(
                      () => _isNewPasswordObscured = !_isNewPasswordObscured),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                labelText: 'confirmar_contrasea'.tr(),
                hintText: 'repite_la_nueva_contrasea'.tr(),
                icon: HugeIcons.strokeRoundedResetPassword,
                obscureText: _isConfirmPasswordObscured,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, confirma tu contraseña.';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Las contraseñas no coinciden.';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordObscured
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => setState(() => _isConfirmPasswordObscured =
                      !_isConfirmPasswordObscured),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ModalButton(
            text: 'cancelar'.tr(),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ModalButton(
            text: 'guardar'.tr(),
            isPrimary: true,
            onPressed: _handleChangePassword,
          ),
        ],
      ),
    );
  }
}