// lib/view/screens/profile/settings/notification_preferences_screen.dart
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class NotificationPreferencesScreen extends StatelessWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        final prefs =
            userViewModel.currentUser?.notificationPreferences ??
            {
              'reminders': true,
              'changes': true,
              'news': true,
              'requests': true, // Se añade el valor por defecto aquí también
            };

        return Scaffold(
          backgroundColor: AppColors.backgroundColor(context),
          appBar: AppBar(
            title: const Text('Notificaciones'),
            backgroundColor: AppColors.backgroundColor(context),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Column(
                children: [
                  _SwitchRow(
                    title: 'Solicitudes Enviadas',
                    subtitle:
                        'Recibe una confirmación cuando enviamos tu solicitud de cita.',
                    value: prefs['requests'] ?? true,
                    onChanged: (newValue) {
                      userViewModel.updateNotificationPreference(
                        'requests',
                        newValue,
                      );
                    },
                  ),
                  _SwitchRow(
                    title: 'Recordatorios de Cita',
                    subtitle: 'Recibe alertas 24 y 48 horas antes de tu cita.',
                    value: prefs['reminders'] ?? true,
                    onChanged: (newValue) {
                      userViewModel.updateNotificationPreference(
                        'reminders',
                        newValue,
                      );
                    },
                  ),
                  _SwitchRow(
                    title: 'Confirmaciones y Cambios',
                    subtitle:
                        'Entérate cuando tu cita sea confirmada, cancelada o reprogramada.',
                    value: prefs['changes'] ?? true,
                    onChanged: (newValue) {
                      userViewModel.updateNotificationPreference(
                        'changes',
                        newValue,
                      );
                    },
                  ),
                  _SwitchRow(
                    title: 'Novedades y Anuncios',
                    subtitle: 'Comunicaciones del sistema de salud.',
                    value: prefs['news'] ?? true,
                    onChanged: (newValue) {
                      userViewModel.updateNotificationPreference(
                        'news',
                        newValue,
                      );
                    },
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;
  final bool isLast;

  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primaryColor(context),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
      ],
    );
  }
}
