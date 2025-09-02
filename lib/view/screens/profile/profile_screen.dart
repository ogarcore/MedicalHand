// lib/view/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 28),
            _buildSectionCard(
              title: 'Información Personal',
              icon: HugeIcons.strokeRoundedUserCircle02,
              children: [
                _buildInfoRow('Nombre Completo', 'Oliver Steven García Corea'),
                _buildInfoRow('Fecha de Nacimiento', '21 de Enero, 2003'),
                _buildInfoRow('Cédula', '001-150590-0001A'),
                _buildInfoRow('Teléfono', '+505 8888-8888'),
                _buildInfoRow('Dirección', 'Managua, Nicaragua'),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Información Médica',
              icon: HugeIcons.strokeRoundedHealth,
              children: [
                _buildInfoRow('Tipo de Sangre', 'O+'),
                _buildInfoRow('Alergias', 'Penicilina, Mariscos'),
                _buildInfoRow('Padecimientos Crónicos', 'Hipertensión Leve'),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Ajustes de la Cuenta',
              icon: HugeIcons.strokeRoundedSettings01,
              isSettings: true,
              children: [
                _buildSettingsRow('Cambiar Contraseña', context),
                _buildSettingsRow('Gestionar Notificaciones', context),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget para la cabecera del perfil
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withAlpha(40),
              border: Border.all(
                color: AppColors.primaryColor.withAlpha(80),
                width: 2,
              ),
            ),
            child: Icon(
              HugeIcons.strokeRoundedUser,
              size: 42,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Oliver García',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Perfil Verificado',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textLightColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Miembro desde Enero 2024',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLightColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget reutilizable para las tarjetas de sección
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool isSettings = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.primaryColor, size: 20),
                  ),
                  const SizedBox(width: 14),
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
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      HugeIcons.strokeRoundedEdit01,
                      size: 20,
                      color: AppColors.primaryColor,
                    ),
                    onPressed: () {},
                    tooltip: 'Editar',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // Widget para mostrar una fila de información (label y valor)
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para las filas de ajustes que parecen botones
  Widget _buildSettingsRow(String title, BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}
