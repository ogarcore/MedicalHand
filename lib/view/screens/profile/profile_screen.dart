// lib/view/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view/screens/profile/widgets/edit_medical_info_screen.dart';
import 'package:p_hn25/view/screens/profile/widgets/edit_personal_info_screen.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textColor),
      ),
      body: Consumer<UserViewModel>(
        builder: (context, userViewModel, child) {
          if (userViewModel.isLoading && userViewModel.currentUser == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColor,
                ),
              ),
            );
          }

          final user = userViewModel.currentUser;
          if (user == null) {
            return const Center(
              child: Text('No se pudo cargar la información del perfil.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 20),
                _buildSectionCard(
                  context: context,
                  title: 'Información Personal',
                  icon: HugeIcons.strokeRoundedUserCircle02,
                  onEditPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditPersonalInfoScreen(user: user),
                      ),
                    );
                  },
                  children: [
                    _buildInfoRow(
                      'Nombre Completo',
                      '${user.firstName} ${user.lastName}',
                    ),
                    _buildInfoRow(
                      'Fecha de Nacimiento',
                      _formatDateOfBirth(user),
                    ),
                    _buildInfoRow('Cédula', user.idNumber),
                    _buildInfoRow('Teléfono', user.phoneNumber),
                    _buildInfoRow('Dirección', user.address),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  context: context,
                  title: 'Información Médica',
                  icon: HugeIcons.strokeRoundedHealth,
                  onEditPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditMedicalInfoScreen(user: user),
                      ),
                    );
                  },
                  children: [
                    _buildInfoRow(
                      'Tipo de Sangre',
                      user.medicalInfo?['bloodType'] ?? 'No especificado',
                    ),
                    _buildInfoRow(
                      'Alergias',
                      user.medicalInfo?['knownAllergies'] ??
                          'Ninguna reportada',
                    ),
                    _buildInfoRow(
                      'Padecimientos Crónicos',
                      _formatChronicDiseases(user),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  context: context,
                  title: 'Ajustes de la Cuenta',
                  icon: HugeIcons.strokeRoundedSettings01,
                  isSettings: true,
                  children: [
                    _buildSettingsRow('Cambiar Contraseña', context),
                    _buildSettingsRow('Gestionar Notificaciones', context),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
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
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withAlpha(30),
              border: Border.all(
                color: AppColors.primaryColor.withAlpha(100),
                width: 1.5,
              ),
            ),
            child: const Icon(
              HugeIcons.strokeRoundedUser,
              size: 32,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.firstName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.verified,
                            size: 14,
                            color: AppColors.primaryColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Perfil Verificado',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textLightColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool isSettings = false,
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
              if (!isSettings)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      HugeIcons.strokeRoundedEdit01,
                      size: 16,
                      color: AppColors.primaryColor,
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

  Widget _buildSettingsRow(String title, BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}
