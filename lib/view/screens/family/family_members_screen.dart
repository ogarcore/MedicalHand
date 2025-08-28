// lib/view/screens/family/family_members_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class FamilyMembersScreen extends StatelessWidget {
  const FamilyMembersScreen({super.key});

  // Datos de ejemplo para los familiares
  final List<Map<String, String>> familyMembers = const [ ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Gestión de Familiares'),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      body: familyMembers.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: familyMembers.length,
                    itemBuilder: (context, index) {
                      final member = familyMembers[index];
                      return _buildFamilyMemberCard(
                        name: member['name']!,
                        relationship: member['relationship']!,
                        iconType: member['icon']!,
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: familyMembers.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton.extended(
                onPressed: () {
                  // Lógica para añadir un nuevo familiar
                },
                label: const Text('Añadir Familiar'),
                icon: const Icon(HugeIcons.strokeRoundedAdd01, size: 22),
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withAlpha(35),
                shape: BoxShape.circle,
              ),
              child: Icon(
                HugeIcons.strokeRoundedUserGroup02,
                size: 60,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            
            Text(
              'Administra los perfiles de tu familia',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Añade a tus familiares para gestionar sus perfiles médicos, '
              'historial clínico y citas de manera centralizada. '
              'Mantén toda la información de salud de tu familia en un solo lugar.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textLightColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            _buildFeatureRow(
              icon: HugeIcons.strokeRoundedClinic,
              text: 'Historial médico compartido',
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(
              icon: HugeIcons.strokeRoundedCalendarLock02,
              text: 'Gestión de citas familiar',
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(
              icon: HugeIcons.strokeRoundedSquareLockPassword,
              text: 'Acceso seguro y controlado',
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Lógica para añadir familiar
                },
                icon: const Icon(HugeIcons.strokeRoundedAdd01, size: 20),
                label: const Text(
                  'Comenzar - Añadir Primer Familiar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow({required IconData icon, required String text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primaryColor,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textColor,
          ),
        ),
      ],
    );
  }

  // Widget reutilizable para las tarjetas de familiares
  Widget _buildFamilyMemberCard({
    required String name,
    required String relationship,
    required String iconType,
  }) {
    IconData getIcon() {
      switch (iconType) {
        case 'woman':
          return HugeIcons.strokeRoundedWoman;
        case 'man':
          return HugeIcons.strokeRoundedMan;
        case 'child':
          return HugeIcons.strokeRoundedChild;
        case 'elder':
          return HugeIcons.strokeRoundedUserAccount;
        default:
          return HugeIcons.strokeRoundedUser;
      }
    }

    Color getIconColor() {
      switch (iconType) {
        case 'woman':
          return const Color(0xFFEC407A);
        case 'man':
          return const Color(0xFF42A5F5);
        case 'child':
          return const Color(0xFFFFA726);
        case 'elder':
          return const Color(0xFFAB47BC);
        default:
          return AppColors.primaryColor;
      }
    }

    String getRelationshipText() {
      switch (relationship.toLowerCase()) {
        case 'mother':
          return 'Madre';
        case 'father':
          return 'Padre';
        case 'son':
          return 'Hijo';
        case 'daughter':
          return 'Hija';
        case 'wife':
          return 'Esposa';
        case 'husband':
          return 'Esposo';
        case 'grandmother':
          return 'Abuela';
        case 'grandfather':
          return 'Abuelo';
        default:
          return relationship;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Lógica para ver el perfil del familiar
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: getIconColor().withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    getIcon(),
                    size: 24,
                    color: getIconColor(),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: getIconColor().withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          getRelationshipText(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: getIconColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Botón de acción
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: AppColors.textLightColor,
                  ),
                  onPressed: () {
                    // Lógica para ver el perfil del familiar
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}