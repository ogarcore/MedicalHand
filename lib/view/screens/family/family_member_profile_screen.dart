// lib/view/screens/family/family_member_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view/widgets/custom_modal.dart';
import 'package:p_hn25/view_model/family_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class FamilyMemberProfileScreen extends StatelessWidget {
  final UserModel member;
  const FamilyMemberProfileScreen({super.key, required this.member});

  String _formatDateOfBirth(UserModel user) {
    initializeDateFormatting('es_ES', null);
    return DateFormat(
      'd \'de\' MMMM, y',
      'es_ES',
    ).format(user.dateOfBirth.toDate());
  }

  String _formatChronicDiseases(UserModel user) {
    final diseases = user.medicalInfo?['chronicDiseases'] as List?;
    if (diseases == null || diseases.isEmpty) {
      return 'Ninguna reportada';
    }
    return diseases.join(', ');
  }

  void _showDeleteConfirmation(
    BuildContext context,
    FamilyViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomModal(
          title: 'Eliminar Perfil Familiar',
          subtitle: 'Esta acción no se puede deshacer',
          icon: HugeIcons.strokeRoundedDelete02,
          content: Text(
            '¿Estás seguro de que deseas eliminar a ${member.firstName} ${member.lastName} de tu lista de familiares?',
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          actions: [
            ModalButton(
              text: 'Cancelar',
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ModalButton(
              text: 'Eliminar',
              isWarning: true,
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final success = await viewModel.deleteFamilyMember(member.uid);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? '${member.firstName} eliminado.'
                            : 'Error al eliminar.',
                      ),
                      backgroundColor: success
                          ? AppColors.successColor(context)
                          : AppColors.warningColor(context),
                    ),
                  );
                  if (success) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final familyViewModel = Provider.of<FamilyViewModel>(
      context,
      listen: false,
    );

    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final currentUser = userViewModel.currentUser;
    final activeProfile = userViewModel.activeProfile;

    final bool isTutorViewing = currentUser?.uid == activeProfile?.uid;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Perfil de ${member.firstName}',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            _buildSectionCard(
              context: context,
              title: 'Información Personal',
              icon: HugeIcons.strokeRoundedUserCircle02,
              showEditButton: isTutorViewing,
              onEditPressed: () {},
              children: [
                _buildInfoRow(
                  context,
                  'Nombre Completo',
                  '${member.firstName} ${member.lastName}',
                ),
                _buildInfoRow(
                  context,
                  'Fecha de Nacimiento',
                  _formatDateOfBirth(member),
                ),
                _buildInfoRow(context, 'Cédula', member.idNumber),
                _buildInfoRow(context, 'Teléfono', member.phoneNumber),
                _buildInfoRow(context, 'Dirección', member.address),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              context: context,
              title: 'Información Médica',
              icon: HugeIcons.strokeRoundedHealth,
              showEditButton: isTutorViewing,
              onEditPressed: () {},
              children: [
                _buildInfoRow(
                  context,
                  'Tipo de Sangre',
                  member.medicalInfo?['bloodType'] ?? 'No especificado',
                ),
                _buildInfoRow(
                  context,
                  'Alergias',
                  member.medicalInfo?['knownAllergies'] ?? 'Ninguna reportada',
                ),
                _buildInfoRow(
                  context,
                  'Padecimientos Crónicos',
                  _formatChronicDiseases(member),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Sección de Configuración de Cuenta (con el mismo diseño)
            if (isTutorViewing)
              _buildSectionCard(
                context: context,
                title: 'Configuración de Cuenta',
                icon: HugeIcons.strokeRoundedSettings02,
                showEditButton: false,
                onEditPressed: () {},
                children: [
                  _buildActionRow(
                    'Eliminar perfil familiar',
                    HugeIcons.strokeRoundedDelete02,
                    AppColors.warningColor(context),
                    () => _showDeleteConfirmation(context, familyViewModel),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool showEditButton = false,
    VoidCallback? onEditPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor(context).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.primaryColor(context),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor(context),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              if (showEditButton)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor(context).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      HugeIcons.strokeRoundedEdit01,
                      size: 16,
                      color: AppColors.primaryColor(context),
                    ),
                    onPressed: onEditPressed,
                    padding: EdgeInsets.zero,
                    tooltip: 'Editar',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? 'No especificado' : value,
              style: TextStyle(
                color: AppColors.textColor(context),
                fontSize: 14.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              HugeIcons.strokeRoundedArrowRight01,
              color: color.withOpacity(0.7),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
