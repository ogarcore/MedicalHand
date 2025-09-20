// lib/view/screens/home/widgets/home_app_bar.dart
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'home_app_bar_logic.dart';
import 'profile_button.dart';
import 'notification_icon_button.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// CAMBIO: La clase ahora hereda de State y "mezcla" la lógica con 'with'.
class _HomeAppBarState extends State<HomeAppBar> with HomeAppBarLogic {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: AppColors.backgroundColor,
      surfaceTintColor: Colors.transparent,
      title: ProfileButton(
        buttonKey: profileButtonKey, // Usa la variable del mixin
        isMenuOpen: isMenuOpen, // Usa la variable del mixin
        onTap: () {
          if (!isMenuOpen) {
            showProfileMenu(); // Usa el método del mixin
          }
        },
      ),
      actions: [
        NotificationIconButton(onPressed: navigateToNotificationsScreen),
        const SizedBox(width: 8),
      ],
    );
  }
}
