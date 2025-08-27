// lib/view/screens/history/widgets/empty_history_view.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class EmptyHistoryView extends StatelessWidget {
  const EmptyHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // Tu código de _buildEmptyState va aquí, sin cambios.
    return Center( 
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(HugeIcons.strokeRoundedFolderFavourite, size: 60, color: AppColors.primaryColor),
              ),
              const SizedBox(height: 24),
              const Text('No hay historial clínico', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textColor)),
              const SizedBox(height: 12),
              Text('Tu historial médico aparecerá aquí', style: TextStyle(fontSize: 16, color: Colors.grey.shade600), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Solicitar historial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
        ),
    );
  }
}