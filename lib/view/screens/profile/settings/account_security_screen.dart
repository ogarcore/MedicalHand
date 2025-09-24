// lib/view/screens/profile/settings/account_security_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/utils/validators.dart';
import 'package:p_hn25/view/widgets/custom_modal.dart';
import 'package:p_hn25/view/widgets/custom_text_field.dart';
// CAMBIO 1: Se importa FirebaseAuth para verificar el proveedor de autenticación
import 'package:firebase_auth/firebase_auth.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  final TextEditingController _confirmController = TextEditingController();
  bool _isDeleteButtonEnabled = false;

  void _showDeleteAccountFlow(BuildContext context) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomModal(
        icon: HugeIcons.strokeRoundedSad01,
        title: 'Lamentamos que te vayas',
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tu opinión es muy importante para nosotros. '
                'Si tienes un momento, cuéntanos por qué quieres eliminar tu cuenta.',
                style: TextStyle(
                  color: AppColors.textLightColor(context),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                labelText: "Motivo de la eliminación",
                icon: HugeIcons.strokeRoundedAlertDiamond,
                controller: reasonController,
                hintText: 'Explícanos por qué deseas cerrar la cuenta...',
                maxLines: 3,
                validator: AppValidators.validateRescheduleReason,
              ),
            ],
          ),
        ),
        actions: [
          ModalButton(
            text: 'Cancelar',
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          ModalButton(
            text: 'Siguiente',
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
            return CustomModal(
              icon: HugeIcons.strokeRoundedAlertDiamond,
              title: '¿Estás seguro?',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Esta acción es permanente. Todos tus datos serán eliminados definitivamente.',
                    style: TextStyle(
                      color: AppColors.textLightColor(context),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Para confirmar, escribe la palabra "ELIMINAR" en el campo de abajo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    labelText: "Escribelo aquí",
                    icon: HugeIcons.strokeRoundedAlertDiamond,
                    controller: _confirmController,
                    hintText: 'ELIMINAR',
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
                        _isDeleteButtonEnabled = (value == 'ELIMINAR');
                      });
                    },
                  ),
                ],
              ),
              actions: [
                ModalButton(
                  text: 'Cancelar',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                ModalButton(
                  text: 'Sí, eliminar',
                  isWarning: true,
                  onPressed: _isDeleteButtonEnabled
                      ? () {
                          Navigator.of(dialogContext).pop();
                        }
                      : () {},
                ),
              ],
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

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: const Text('Cuenta y Seguridad'),
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
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
                      title: 'Cambiar Contraseña',
                      onTap: () {},
                    ),
                    Divider(height: 1, color: Colors.grey.shade200, indent: 16),
                  ],
                  _SettingsOptionRow(
                    title: 'Eliminar Cuenta',
                    onTap: () => _showDeleteAccountFlow(context),
                    textColor: AppColors.warningColor(context),
                  ),
                ],
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
