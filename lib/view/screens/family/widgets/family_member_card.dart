// lib/view/screens/family/widgets/family_member_card.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/user_model.dart';
import '../family_member_profile_screen.dart'; // CAMBIO: Importamos la nueva pantalla

class FamilyMemberCard extends StatelessWidget {
  final UserModel member;

  const FamilyMemberCard({super.key, required this.member});

  String get _getRelationship {
    return member.medicalInfo?['kinship'] as String? ?? 'Familiar';
  }

  IconData get _getIcon {
    return HugeIcons.strokeRoundedUser;
  }

  Color get _getIconColor {
    return AppColors.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(member.uid),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        // ... (lógica de onDismissed sin cambios)
      },
      background: Container(
        // ... (código del fondo de eliminar sin cambios)
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            // CAMBIO: El onTap ahora navega a la pantalla de perfil del familiar
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FamilyMemberProfileScreen(member: member),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            splashColor: AppColors.primaryColor.withAlpha(40),
            highlightColor: AppColors.primaryColor.withAlpha(20),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getIconColor.withAlpha(40),
                          _getIconColor.withAlpha(60),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getIconColor.withAlpha(100),
                        width: 2,
                      ),
                    ),
                    child: Icon(_getIcon, size: 24, color: _getIconColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${member.firstName} ${member.lastName}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textColor,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getIconColor.withAlpha(30),
                                _getIconColor.withAlpha(50),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getIconColor.withAlpha(80),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getRelationship,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getIconColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[200]!, width: 1.5),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
