import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view/screens/profile/edit_medical_info_screen.dart';
import 'package:p_hn25/view/screens/profile/edit_personal_info_screen.dart';
import 'package:p_hn25/view/screens/profile/settings/app_preferences_screen.dart';
import 'package:p_hn25/view/screens/profile/settings/notification_preferences_screen.dart';
import 'package:p_hn25/view/screens/profile/settings/account_security_screen.dart';
import 'package:shimmer/shimmer.dart'; // 🔥 1. IMPORTAMOS EL PAQUETE SHIMMER
import 'info_row.dart';
import 'profile_header.dart';
import 'settings_row.dart';
import 'info_card.dart';
import 'profile_section_header.dart';
import 'emergency_contact_dialog.dart';
import 'emergency_contact_row.dart';
import 'profile_divider.dart';

class ProfileContentView extends StatelessWidget {
  final UserModel user;

  const ProfileContentView({super.key, required this.user});

  String _formatDateOfBirth() {
    initializeDateFormatting('es_ES', null);
    return DateFormat(
      'd \'de\' MMMM, y',
      'es_ES',
    ).format(user.dateOfBirth.toDate());
  }

  String _formatChronicDiseases() {
    final diseases = user.medicalInfo?['chronicDiseases'] as List?;
    return (diseases == null || diseases.isEmpty)
        ? 'Ninguna reportada'
        : diseases.join(', ');
  }

  Map<String, dynamic> _getEmergencyContact() {
    final contact = user.medicalInfo?['emergencyContact'] as Map?;
    return contact?.map((key, value) => MapEntry(key.toString(), value)) ?? {};
  }

  void _showEditEmergencyContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => EmergencyContactDialog(user: user),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.black45,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.white, size: 60),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final emergencyContact = _getEmergencyContact();
    final hasEmergencyContact =
        emergencyContact.isNotEmpty &&
        emergencyContact['name'] != null &&
        emergencyContact['phone'] != null;
    
    final String? idFrontUrl = user.verification?['idFrontUrl'];
    final String? idBackUrl = user.verification?['idBackUrl'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: ProfileHeader(user: user),
          ),
          ProfileSectionHeader(
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
          ),
          InfoCard(
            children: [
              InfoRow(
                label: 'Nombre Completo',
                value: '${user.firstName} ${user.lastName}',
                isFirst: true,
              ),
              const ProfileDivider(),
              InfoRow(
                label: 'Fecha de Nacimiento',
                value: _formatDateOfBirth(),
              ),
              const ProfileDivider(),
              Column(
                children: [
                  InfoRow(label: 'Cédula', value: user.idNumber),
                  if (idFrontUrl != null || idBackUrl != null)
                    _buildIdImageViewer(context, idFrontUrl, idBackUrl),
                ],
              ),
              const SizedBox(height: 10),
              const ProfileDivider(),
              InfoRow(label: 'Teléfono', value: user.phoneNumber),
              const ProfileDivider(),
              InfoRow(label: 'Dirección', value: user.address, isLast: true),
            ],
          ),
          const SizedBox(height: 16),
          ProfileSectionHeader(
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
          ),
          InfoCard(
            children: [
              InfoRow(
                label: 'Tipo de Sangre',
                value: user.medicalInfo?['bloodType'] ?? 'No especificado',
                isFirst: true,
              ),
              const ProfileDivider(),
              InfoRow(
                label: 'Alergias',
                value: user.medicalInfo?['knownAllergies'] ?? 'Ninguna reportada',
              ),
              const ProfileDivider(),
              InfoRow(
                label: 'Padecimientos Crónicos',
                value: _formatChronicDiseases(),
              ),
              const ProfileDivider(),
              EmergencyContactRow(
                hasContact: hasEmergencyContact,
                contact: emergencyContact,
                onEdit: () => _showEditEmergencyContactDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const ProfileSectionHeader(
            title: 'Ajustes y Preferencias',
            icon: HugeIcons.strokeRoundedSettings02,
          ),
          InfoCard(
            children: [
              SettingsRow(
                title: 'Preferencias de la Aplicación',
                icon: HugeIcons.strokeRoundedPhoneArrowDown,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AppPreferencesScreen()),
                ),
                isFirst: true,
              ),
              const ProfileDivider(),
              SettingsRow(
                title: 'Preferencias de Notificaciones',
                icon: HugeIcons.strokeRoundedNotification01,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationPreferencesScreen()),
                ),
              ),
              const ProfileDivider(),
              SettingsRow(
                title: 'Gestión de la Cuenta y Seguridad',
                icon: HugeIcons.strokeRoundedShield01,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountSecurityScreen()),
                ),
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Tu información está segura con nosotros',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdImageViewer(BuildContext context, String? frontUrl, String? backUrl) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (frontUrl != null)
            Expanded(
              child: _buildImageContainer('Frente', frontUrl, context),
            ),
          if (frontUrl != null && backUrl != null)
            const SizedBox(width: 16),
          if (backUrl != null)
            Expanded(
              child: _buildImageContainer('Dorso', backUrl, context),
            ),
        ],
      ),
    );
  }

  Widget _buildImageContainer(String label, String url, BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showImageDialog(context, url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 100,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: Image.network(
                url,
                fit: BoxFit.cover,
                // 🔥 2. SE REEMPLAZA EL CIRCULARPROGRESSINDICATOR POR EL SHIMMER
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child; // Cuando la imagen carga, se muestra
                  // Mientras carga, se muestra el efecto shimmer
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      color: Colors.white, // El color base del shimmer
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.error_outline,
                    color: AppColors.warningColor(context),
                    size: 40,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}