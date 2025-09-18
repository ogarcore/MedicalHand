// lib/view/screens/history/widgets/history_card.dart
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'history_card_header.dart';
import 'history_card_details.dart';

class HistoryCard extends StatelessWidget {
  final int index;
  final String date;
  final String specialty;
  final String doctor;
  final String diagnosis;
  final String prescription;
  final String labResults;
  final String hospital;
  final bool hasDownloadable;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;
  final GlobalKey cardKey;

  const HistoryCard({
    super.key,
    required this.index,
    required this.date,
    required this.specialty,
    required this.doctor,
    required this.diagnosis,
    required this.prescription,
    required this.labResults,
    required this.hospital,
    required this.hasDownloadable,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.cardKey,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: cardKey,
      color: Colors.white.withAlpha(220),
      elevation: 3,
      shadowColor: AppColors.primaryColor.withAlpha(20),
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () async {
              onExpansionChanged(!isExpanded);
              if (!isExpanded) {
                await Future.delayed(const Duration(milliseconds: 200));
                if (cardKey.currentContext != null) {
                  Scrollable.ensureVisible(
                    cardKey.currentContext!,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    alignment: 0.3,
                  );
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: HistoryCardHeader(
                hospital: hospital,
                date: date,
                doctor: doctor,
                diagnosis: diagnosis,
                isExpanded: isExpanded,
                specialty: specialty,
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded
                ? HistoryCardDetails(
                    specialty: specialty,
                    doctor: doctor,
                    diagnosis: diagnosis,
                    prescription: prescription,
                    labResults: labResults,
                    hasDownloadable: hasDownloadable,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
