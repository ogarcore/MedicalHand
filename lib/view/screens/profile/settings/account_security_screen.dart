// lib/view/screens/profile/settings/account_security_screen.dart
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '¿Estás seguro?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Esta acción es permanente y no se puede deshacer. Se eliminarán todos tus datos, incluyendo tu historial de citas.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Aquí iría la lógica para eliminar la cuenta
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warningColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sí, eliminar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Cuenta y Seguridad'),
        backgroundColor: AppColors.backgroundColor,
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
                  _SettingsOptionRow(
                    title: 'Cambiar Contraseña',
                    onTap: () {
                      // Navegar a la pantalla de cambiar contraseña
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200, indent: 16),
                  _SettingsOptionRow(
                    title: 'Eliminar Cuenta',
                    onTap: () => _showDeleteConfirmationDialog(context),
                    textColor: AppColors.warningColor, // Color de advertencia
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

// Widget para las filas de opciones
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
          color: textColor ?? AppColors.textColor,
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
