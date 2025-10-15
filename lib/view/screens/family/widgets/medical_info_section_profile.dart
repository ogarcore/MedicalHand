// lib/view/screens/family/widgets/medical_info_section.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view/screens/profile/widgets/info_card.dart';
import 'package:p_hn25/view/screens/profile/widgets/info_row.dart';
import 'package:p_hn25/view/screens/profile/widgets/profile_divider.dart';
import 'package:p_hn25/view/screens/profile/widgets/profile_section_header.dart';

class MedicalInfoSection extends StatelessWidget {
  final UserModel member;
  final VoidCallback? onEditPressed;

  const MedicalInfoSection({
    super.key,
    required this.member,
    this.onEditPressed,
  });

  String _formatChronicDiseases() {
    final diseases = member.medicalInfo?['chronicDiseases'] as List?;
    if (diseases == null || diseases.isEmpty) {
      return 'ninguna_reportada'.tr();
    }
    return diseases.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileSectionHeader(
          title: 'informacin_mdica'.tr(),
          icon: HugeIcons.strokeRoundedHealth,
          onEditPressed: onEditPressed,
        ),
        InfoCard(
          children: [
            InfoRow(
              label: 'tipo_de_sangre'.tr(),
              value: member.medicalInfo?['bloodType'] ?? 'No especificado',
              isFirst: true,
            ),
            const ProfileDivider(),
            InfoRow(
              label: 'alergias_conocidas'.tr(),
              value: member.medicalInfo?['knownAllergies'] ?? 'ninguna_reportada'.tr(),
            ),
            const ProfileDivider(),
            InfoRow(
              label: 'padecimientos_crnicos'.tr(),
              value: _formatChronicDiseases(),
              isLast: true,
            ),
          ],
        ),
      ],
    );
  }
}