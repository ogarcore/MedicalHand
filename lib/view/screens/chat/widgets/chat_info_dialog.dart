import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class ChatInfoDialog extends StatelessWidget {
  const ChatInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor,
                        Color.lerp(primaryColor, Colors.blue.shade600, 0.4)!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    HugeIcons.strokeRoundedInformationDiamond,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Acerca del Asistente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoItem(
              context: context,
              icon: Icons.memory_rounded,
              title: 'Memoria Limitada',
              description:
                  'El asistente solo mantiene contexto de los últimos mensajes de la conversación actual.',
              color: primaryColor,
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              context: context,
              icon: HugeIcons.strokeRoundedShieldKey,
              title: 'Privacidad',
              description:
                  'Tus conversaciones son seguras y se procesan de forma anónima.',
              color: AppColors.accentColor(context).withAlpha(180),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              context: context,
              icon: Icons.medical_information_rounded,
              title: 'Propósito',
              description:
                  'Este es un asistente para consejos de bienestar general, no para diagnósticos médicos.',
              color: AppColors.graceColor(context).withAlpha(170),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Entendido',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textLightColor(context),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}