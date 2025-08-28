// lib/view/screens/home/widgets/home_app_bar.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view/screens/family/family_members_screen.dart';
import 'package:p_hn25/view/screens/profile/profile_screen.dart';
import 'package:p_hn25/view/screens/support/support_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:p_hn25/view/screens/splash/splash_screen.dart';
import 'package:p_hn25/view/widgets/custom_modal.dart';

// Importa los nuevos widgets
import 'profile_button.dart';
import 'notification_icon_button.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeAppBarState extends State<HomeAppBar> {
  bool _isMenuOpen = false;
  final GlobalKey _profileButtonKey = GlobalKey();

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomModal(
          icon: HugeIcons.strokeRoundedLogout03,
          title: 'Cerrar Sesión',
          content: const Text(
            '¿Estás seguro de que deseas cerrar sesión?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          actions: <Widget>[
            ModalButton(
              text: 'Cancelar',
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ModalButton(
              text: 'Aceptar',
              isWarning: true,
              onPressed: () async {
                final navigator = Navigator.of(context);
                Navigator.of(dialogContext).pop();
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showProfileMenu() {
    setState(() {
      _isMenuOpen = true;
    });

    final RenderBox renderBox =
        _profileButtonKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    final navigator = Navigator.of(context);

    const double menuWidth = 190.0;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx - 60,
        position.dy + size.height + 6.0,
        position.dx + size.width,
        position.dy,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          child: SizedBox(
            width: menuWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Oliver García (yo)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(height: 8),
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              const Icon(
                HugeIcons.strokeRoundedUser,
                color: AppColors.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Mi Perfil',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'family',
          child: Row(
            children: [
              const Icon(
                HugeIcons.strokeRoundedUserGroup02,
                color: AppColors.accentColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Mis Familiares',
                style: TextStyle(color: AppColors.accentColor),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'support',
          child: Row(
            children: [
              Icon(
                HugeIcons.strokeRoundedCustomerService01,
                color: AppColors.textColor.withAlpha(178),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text('Soporte', style: TextStyle(color: AppColors.textColor)),
            ],
          ),
        ),
        const PopupMenuDivider(height: 16),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(
                HugeIcons.strokeRoundedLogout03,
                color: AppColors.warningColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: AppColors.warningColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withAlpha(50), width: 1),
      ),
      elevation: 8,
      color: Colors.white.withAlpha(250),
    ).then((selectedValue) {
      if (!mounted) return;

      setState(() {
        _isMenuOpen = false;
      });

      if (selectedValue == null) return;

      if (selectedValue == 'profile') {
        navigator.push(
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      } else if (selectedValue == 'family') {
        navigator.push(
          MaterialPageRoute(builder: (_) => const FamilyMembersScreen()),
        );
      } else if (selectedValue == 'support') {
        navigator.push(
          MaterialPageRoute(builder: (_) => const SupportScreen()),
        );
      } else if (selectedValue == 'logout') {
        _showLogoutDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: AppColors.backgroundColor,
      surfaceTintColor: Colors.transparent,
      title: ProfileButton(
        buttonKey: _profileButtonKey,
        isMenuOpen: _isMenuOpen,
        onTap: () {
          if (!_isMenuOpen) {
            _showProfileMenu();
          }
        },
      ),
      actions: const [
        NotificationIconButton(),
        SizedBox(width: 8),
      ],
    );
  }
}