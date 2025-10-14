import 'package:easy_localization/easy_localization.dart';
// lib/view/screens/home/widgets/profile_button.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class ProfileButton extends StatelessWidget {
  final GlobalKey buttonKey;
  final bool isMenuOpen;
  final VoidCallback onTap;

  const ProfileButton({
    super.key,
    required this.buttonKey,
    required this.isMenuOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: buttonKey,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(25),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryColor(context).withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: Icon(
                HugeIcons.strokeRoundedUser,
                color: AppColors.primaryColor(context),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // CAMBIO: El Consumer ahora escucha el 'activeProfile'
            Consumer<UserViewModel>(
              builder: (context, userViewModel, child) {
                if (userViewModel.isLoading &&
                    userViewModel.activeProfile == null) {
                  return Text(
                    'key'.tr(),
                    style: TextStyle(
                      color: AppColors.textColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }

                // Usamos el perfil activo para mostrar el nombre
                final activeProfile = userViewModel.activeProfile;
                final firstName = (activeProfile?.firstName ?? '')
                    .split(' ')
                    .first;
                final lastName = (activeProfile?.lastName ?? '')
                    .split(' ')
                    .first;
                final displayName = "$firstName $lastName".trim();

                return Text(
                  displayName,
                  style: TextStyle(
                    color: AppColors.textColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),

            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Icon(
                isMenuOpen
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                key: ValueKey<bool>(isMenuOpen),
                color: AppColors.textColor(context).withAlpha(178),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
