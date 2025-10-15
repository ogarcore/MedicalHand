import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class ChatDisclaimerBanner extends StatelessWidget {
  const ChatDisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);
     final accentColor = AppColors.accentColor(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor.withAlpha(35),
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
              color: accentColor.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              HugeIcons.strokeRoundedCovidInfo,
              color: accentColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'para_tu_bienestar'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'asistente_para_consejos_de_bienestar_general_consulta_a_un_m'.tr(),
                  style: TextStyle(
                    color: AppColors.textColor(context).withAlpha(200),
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