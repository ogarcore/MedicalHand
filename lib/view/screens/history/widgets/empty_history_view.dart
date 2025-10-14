import 'package:easy_localization/easy_localization.dart';
// lib/view/screens/history/widgets/empty_history_view.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class EmptyHistoryView extends StatelessWidget {
  const EmptyHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(padding: const EdgeInsets.only(top: 120.0)),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryColor(context).withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              HugeIcons.strokeRoundedFolderFavourite,
              size: 50,
              color: AppColors.primaryColor(context),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'no_hay_historial_clnico'.tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'tu_historial_mdico_aparecer_aqu'.tr(),
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
