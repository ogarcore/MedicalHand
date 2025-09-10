// lib/view/screens/family/family_member_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view_model/family_view_model.dart';
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
        return AlertDialog(
          title: const Text('Eliminar Familiar'),
          content: Text(
            '¿Estás seguro de que deseas eliminar a ${member.firstName} de tu lista? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text(
                'Eliminar',
                style: TextStyle(color: AppColors.warningColor),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
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
                          ? AppColors.successColor
                          : AppColors.warningColor,
                    ),
                  );
                  if (success) {
                    Navigator.pop(context); // Regresa a la lista de familiares
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

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Perfil Familiar',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedDelete02),
            onPressed: () => _showDeleteConfirmation(context, familyViewModel),
            tooltip: 'Eliminar Familiar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            _buildSectionCard(
              title: 'Información Personal',
              icon: HugeIcons.strokeRoundedUserCircle02,
              onEditPressed: () {},
              children: [
                _buildInfoRow(
                  'Nombre Completo',
                  '${member.firstName} ${member.lastName}',
                ),
                _buildInfoRow(
                  'Fecha de Nacimiento',
                  _formatDateOfBirth(member),
                ),
                _buildInfoRow('Cédula', member.idNumber),
                _buildInfoRow('Teléfono', member.phoneNumber),
                _buildInfoRow('Dirección', member.address),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Información Médica',
              icon: HugeIcons.strokeRoundedHealth,
              onEditPressed: () {},
              children: [
                _buildInfoRow(
                  'Tipo de Sangre',
                  member.medicalInfo?['bloodType'] ?? 'No especificado',
                ),
                _buildInfoRow(
                  'Alergias',
                  member.medicalInfo?['knownAllergies'] ?? 'Ninguna reportada',
                ),
                _buildInfoRow(
                  'Padecimientos Crónicos',
                  _formatChronicDiseases(member),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widgets de construcción de UI (reutilizados de ProfileScreen)
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
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
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.primaryColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
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

  Widget _buildInfoRow(String label, String value) {
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
              style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 14.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
