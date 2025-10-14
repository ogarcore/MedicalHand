import 'package:easy_localization/easy_localization.dart';
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
            title: Text('notificaciones'.tr()),
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
                    title: 'solicitudes_enviadas'.tr(),
                    subtitle:
                        'recibe_una_confirmacin_cuando_enviamos_tu_solicitud_de_cita'.tr(),
                    value: prefs['requests'] ?? true,
                    onChanged: (newValue) {
                      userViewModel.updateNotificationPreference(
                        'requests',
                        newValue,
                      );
                    },
                  ),
                  _SwitchRow(
                    title: 'recordatorios_de_cita'.tr(),
                    subtitle: 'recibe_alertas_24_y_48_horas_antes_de_tu_cita'.tr(),
                    value: prefs['reminders'] ?? true,
                    onChanged: (newValue) {
                      userViewModel.updateNotificationPreference(
                        'reminders',
                        newValue,
                      );
                    },
                  ),
                  _SwitchRow(
                    title: 'confirmaciones_y_cambios'.tr(),
                    subtitle:
                        'entrate_cuando_tu_cita_sea_confirmada_cancelada_o_reprograma'.tr(),
                    value: prefs['changes'] ?? true,
                    onChanged: (newValue) {
                      userViewModel.updateNotificationPreference(
                        'changes',
                        newValue,
                      );
                    },
                  ),
                  _SwitchRow(
                    title: 'novedades_y_anuncios'.tr(),
                    subtitle: 'comunicaciones_del_sistema_de_salud'.tr(),
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
