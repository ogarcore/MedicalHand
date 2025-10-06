import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class ChatDisclaimerBanner extends StatelessWidget {
  const ChatDisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withAlpha(26),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              HugeIcons.strokeRoundedCovidInfo,
              color: primaryColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Para tu bienestar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Asistente para consejos de bienestar general. Consulta a un médico para diagnósticos.',
                  style: TextStyle(
                    color: AppColors.textLightColor(context),
                    fontSize: 12,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}