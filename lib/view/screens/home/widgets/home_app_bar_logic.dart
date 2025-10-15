import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view/screens/family/family_members_screen.dart';
import 'package:p_hn25/view/screens/home/widgets/home_app_bar.dart';
import 'package:p_hn25/view/screens/notifications/notifications_screen.dart';
import 'package:p_hn25/view/screens/profile/profile_screen.dart';
import 'package:p_hn25/view/screens/splash/splash_screen.dart';
import 'package:p_hn25/view/screens/support/support_screen.dart';
import 'package:p_hn25/view/widgets/custom_modal.dart';
import 'package:p_hn25/view_model/auth_view_model.dart';
import 'package:p_hn25/view_model/family_view_model.dart';
import 'package:p_hn25/view_model/notification_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

mixin HomeAppBarLogic on State<HomeAppBar> {
  bool isMenuOpen = false;
  final GlobalKey profileButtonKey = GlobalKey();

  String _getShortName(UserModel user) {
    final firstName = (user.firstName).split(' ').first;
    final lastName = (user.lastName).split(' ').first;
    return '$firstName $lastName'.trim();
  }

  void navigateToNotificationsScreen() {
    final userId = Provider.of<UserViewModel>(
      context,
      listen: false,
    ).currentUser?.uid;
    if (userId != null) {
      Provider.of<NotificationViewModel>(
        context,
        listen: false,
      ).loadNotifications(userId);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  void showProfileMenu() async {
    setState(() => isMenuOpen = true);

    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final familyViewModel = Provider.of<FamilyViewModel>(
      context,
      listen: false,
    );
    final navigator = Navigator.of(context);

    final currentUser = userViewModel.currentUser;
    final activeProfile = userViewModel.activeProfile;
    if (currentUser == null || activeProfile == null) return;

    final familyMembers = await familyViewModel.getFamilyMembers().first;

    final RenderBox renderBox =
        profileButtonKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    final List<PopupMenuEntry<dynamic>> menuItems = [];

    PopupMenuItem<UserModel> buildProfileMenuItem(
      UserModel profile,
      String label,
    ) {
      final bool isSelected = profile.uid == activeProfile.uid;
      return PopupMenuItem<UserModel>(
        value: profile,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.secondaryColor(context)
                      : AppColors.textColor(context),
                ),
              ),
            ),
            const SizedBox(width: 4),
            if (isSelected)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor(context),
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 8),
          ],
        ),
      );
    }

    menuItems.add(
      buildProfileMenuItem(
        currentUser,
        'nombre_con_parentesis_yo'.tr(
          namedArgs: {'nombre': _getShortName(currentUser)},
        ),
      ),
    );

    if (familyMembers.isNotEmpty) {
      for (var member in familyMembers) {
        menuItems.add(
          buildProfileMenuItem(
            member,
            '${_getShortName(member)} (${member.medicalInfo?['kinship'] ?? 'Familiar'})',
          ),
        );
      }
    }

    menuItems.add(const PopupMenuDivider());
    if (!mounted) return;
    if (activeProfile.uid == currentUser.uid) {
      menuItems.add(
        _buildNavigationMenuItem(
          'profile',
          'mi_perfil'.tr(),
          HugeIcons.strokeRoundedUser,
          AppColors.secondaryColor(context),
        ),
      );
    }
    menuItems.add(
      _buildNavigationMenuItem(
        'family',
        'mis_familiares'.tr(),
        HugeIcons.strokeRoundedUserGroup02,
        AppColors.accentColor(context),
      ),
    );
    menuItems.add(
      _buildNavigationMenuItem(
        'support',
        'soporte'.tr(),
        HugeIcons.strokeRoundedCustomerService01,
        AppColors.textColor(context),
      ),
    );
    menuItems.add(const PopupMenuDivider());
    menuItems.add(
      _buildNavigationMenuItem(
        'logout',
        'cerrar_sesin'.tr(),
        HugeIcons.strokeRoundedLogout03,
        AppColors.warningColor(context),
      ),
    );

    const double menuWidth = 220.0;

    showMenu<dynamic>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx - 160,
        position.dy + size.height + 6.0,
        position.dx + size.width,
        position.dy,
      ),
      items: menuItems,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      constraints: const BoxConstraints(
        minWidth: menuWidth,
        maxWidth: menuWidth,
      ),
      color: Colors.white.withAlpha(250),
    ).then((selectedValue) {
      if (!mounted) return;
      setState(() => isMenuOpen = false);
      if (selectedValue == null) return;

      if (selectedValue is UserModel) {
        userViewModel.changeActiveProfile(selectedValue);
      } else if (selectedValue is String) {
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
          showLogoutDialog();
        }
      }
    });
  }

  PopupMenuItem<String> _buildNavigationMenuItem(
    String value,
    String text,
    IconData icon,
    Color color,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void showLogoutDialog() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomModal(
          icon: HugeIcons.strokeRoundedLogout03,
          title: 'cerrar_sesin'.tr(),
          content: const Text(
            '¿Estás seguro de que deseas cerrar sesión?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          actions: <Widget>[
            ModalButton(
              text: 'cancelar'.tr(),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ModalButton(
              text: 'aceptar'.tr(),
              isWarning: true,
              onPressed: () async {
                final navigator = Navigator.of(context, rootNavigator: true);

                Navigator.of(dialogContext).pop();

                // 2. Transición a una PANTALLA COMPLETA de carga con un fundido suave.
                navigator.push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const _LogoutLoadingScreen(),
                    transitionDuration: const Duration(milliseconds: 500),
                    transitionsBuilder: (_, animation, __, child) =>
                        FadeTransition(opacity: animation, child: child),
                  ),
                );

                // Se da un respiro a la animación antes de empezar el trabajo pesado.
                await Future.delayed(const Duration(milliseconds: 300));
                if (!mounted) return;
                // 3. Realizar el cierre de sesión en segundo plano.
                await authViewModel.signOut(context);

                // 4. Pequeña pausa para que el proceso se sienta deliberado.
                await Future.delayed(const Duration(milliseconds: 500));

                if (!navigator.mounted) return;

                // 5. Navegar a la pantalla de Splash, eliminando todas las rutas
                // anteriores con otro fundido suave.
                navigator.pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const SplashScreen(),
                    transitionDuration: const Duration(milliseconds: 500),
                    transitionsBuilder: (_, animation, __, child) =>
                        FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                          child: child,
                        ),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

/// Widget interno para la pantalla de carga al cerrar sesión.
class _LogoutLoadingScreen extends StatelessWidget {
  const _LogoutLoadingScreen();

  @override
  Widget build(BuildContext context) {
    // Scaffold con fondo sólido para una experiencia de pantalla completa.
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColor(context),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'cerrando_sesin'.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'su_sesin_se_est_cerrando_de_forma_segura'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textColor(context).withAlpha(179),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
