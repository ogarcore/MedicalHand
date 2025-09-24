import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view/screens/profile/settings/account_security_screen.dart';
import 'package:p_hn25/view/screens/profile/settings/app_preferences_screen.dart';
import 'package:p_hn25/view/screens/profile/edit_medical_info_screen.dart';
import 'package:p_hn25/view/screens/profile/edit_personal_info_screen.dart';
import 'package:p_hn25/view/screens/profile/settings/notification_preferences_screen.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'widgets/info_row.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_section_card.dart';
import 'widgets/settings_row.dart';

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
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textColor(context)),
      ),
      body: Consumer<UserViewModel>(
        builder: (context, userViewModel, child) {
          if (userViewModel.isLoading && userViewModel.currentUser == null) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColor(context),
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
                ProfileHeader(user: user),
                const SizedBox(height: 20),
                ProfileSectionCard(
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
                    InfoRow(
                      'Nombre Completo',
                      '${user.firstName} ${user.lastName}',
                    ),
                    InfoRow('Fecha de Nacimiento', _formatDateOfBirth(user)),
                    InfoRow('Cédula', user.idNumber),
                    InfoRow('Teléfono', user.phoneNumber),
                    InfoRow('Dirección', user.address),
                  ],
                ),
                const SizedBox(height: 16),
                ProfileSectionCard(
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
                    InfoRow(
                      'Tipo de Sangre',
                      user.medicalInfo?['bloodType'] ?? 'No especificado',
                    ),
                    InfoRow(
                      'Alergias',
                      user.medicalInfo?['knownAllergies'] ??
                          'Ninguna reportada',
                    ),
                    InfoRow(
                      'Padecimientos Crónicos',
                      _formatChronicDiseases(user),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ProfileSectionCard(
                  title: 'Ajustes',
                  icon: HugeIcons.strokeRoundedSettings02,
                  isSettings: true,
                  children: [
                    SettingsRow(
                      title: 'Preferencias de la Aplicación',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AppPreferencesScreen(),
                          ),
                        );
                      },
                    ),
                    SettingsRow(
                      title: 'Preferencias de Notificaciones',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const NotificationPreferencesScreen(),
                          ),
                        );
                      },
                    ),
                    SettingsRow(
                      title: 'Gestión de la Cuenta y Seguridad',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AccountSecurityScreen(),
                          ),
                        );
                      },
                    ),
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
}
