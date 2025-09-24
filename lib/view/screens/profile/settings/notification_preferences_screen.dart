// lib/view/screens/profile/settings/notification_preferences_screen.dart
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class NotificationPreferencesScreen extends StatelessWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: AppColors.backgroundColor,
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
                title: 'Recordatorios de Cita',
                subtitle: 'Recibe alertas 24 y 48 horas antes de tu cita.',
                initialValue: true,
              ),
              _SwitchRow(
                title: 'Confirmaciones y Cambios',
                subtitle:
                    'Entérate cuando tu cita sea confirmada, cancelada o reprogramada.',
                initialValue: true,
              ),
              _SwitchRow(
                title: 'Novedades y Anuncios',
                subtitle:
                    'Comunicaciones importantes del sistema de salud (poco frecuente).',
                initialValue: false,
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget interno para mantener el estado de cada interruptor de forma individual
class _SwitchRow extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool initialValue;
  final bool isLast;

  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.initialValue,
    this.isLast = false,
  });

  @override
  State<_SwitchRow> createState() => _SwitchRowState();
}

class _SwitchRowState extends State<_SwitchRow> {
  late bool _switchValue;

  @override
  void initState() {
    super.initState();
    _switchValue = widget.initialValue;
  }

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
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Text(
            widget.subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          trailing: Switch(
            value: _switchValue,
            onChanged: (value) {
              setState(() {
                _switchValue = value;
              });
            },
            activeThumbColor: AppColors.primaryColor,
          ),
        ),
        if (!widget.isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
      ],
    );
  }
}
