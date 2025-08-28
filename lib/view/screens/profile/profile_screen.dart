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
        // AppBar personalizado para la pantalla de perfil
        title: const Text('Mi Perfil'),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
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
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'Información Médica',
            icon: HugeIcons.strokeRoundedHealth,
            children: [
              _buildInfoRow('Tipo de Sangre', 'O+'),
              _buildInfoRow('Alergias', 'Penicilina, Mariscos'),
              _buildInfoRow('Padecimientos Crónicos', 'Hipertensión Leve'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'Ajustes de la Cuenta',
            icon: HugeIcons.strokeRoundedSettings01,
            isSettings: true,
            children: [
              _buildSettingsRow('Cambiar Contraseña', context),
              _buildSettingsRow('Gestionar Notificaciones', context),
            ],
          ),
        ],
      ),
    );
  }

  // Widget para la cabecera del perfil
  Widget _buildProfileHeader() {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryColor.withAlpha(51),
          ),
          child: Icon(HugeIcons.strokeRoundedUser, size: 40, color: AppColors.primaryColor),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Oliver García',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textColor),
            ),
            SizedBox(height: 4),
            Text(
              'Perfil Verificado',
              style: TextStyle(fontSize: 16, color: AppColors.textLightColor),
            ),
          ],
        ),
      ],
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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 10,
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
                  Icon(icon, color: AppColors.primaryColor, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textColor),
                  ),
                ],
              ),
              if (!isSettings)
                IconButton(
                  icon: const Icon(HugeIcons.strokeRoundedEdit01, size: 20),
                  onPressed: () {},
                  tooltip: 'Editar',
                ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  // Widget para mostrar una fila de información (label y valor)
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: AppColors.textColor, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Widget para las filas de ajustes que parecen botones
  Widget _buildSettingsRow(String title, BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: AppColors.textColor, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}