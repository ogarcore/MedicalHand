// lib/view/screens/home/widgets/home_app_bar_logic.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view/screens/family/family_members_screen.dart';
import 'package:p_hn25/view/screens/home/widgets/home_app_bar.dart';
import 'package:p_hn25/view/screens/profile/profile_screen.dart';
import 'package:p_hn25/view/screens/splash/splash_screen.dart';
import 'package:p_hn25/view/screens/support/support_screen.dart';
import 'package:p_hn25/view/widgets/custom_modal.dart';
import 'package:p_hn25/view_model/auth_view_model.dart';
import 'package:p_hn25/view_model/family_view_model.dart';
import 'package:p_hn25/view_model/notification_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import '../../notifications/notifications_screen.dart';

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
      buildProfileMenuItem(currentUser, '${_getShortName(currentUser)} (Yo)'),
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

    if (activeProfile.uid == currentUser.uid) {
      menuItems.add(
        _buildNavigationMenuItem(
          'profile',
          'Mi Perfil',
          HugeIcons.strokeRoundedUser,
          AppColors.successColor(context),
        ),
      );
    }
    menuItems.add(
      _buildNavigationMenuItem(
        'family',
        'Mis Familiares',
        HugeIcons.strokeRoundedUserGroup02,
        AppColors.accentColor(context),
      ),
    );
    menuItems.add(
      _buildNavigationMenuItem(
        'support',
        'Soporte',
        HugeIcons.strokeRoundedCustomerService01,
        AppColors.textColor(context),
      ),
    );
    menuItems.add(const PopupMenuDivider());
    menuItems.add(
      _buildNavigationMenuItem(
        'logout',
        'Cerrar Sesión',
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
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
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
          title: 'Cerrar Sesión',
          content: const Text(
            '¿Estás seguro de que deseas cerrar sesión?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          actions: <Widget>[
            ModalButton(
              text: 'Cancelar',
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ModalButton(
              text: 'Aceptar',
              isWarning: true,
              onPressed: () async {
                final navigator = Navigator.of(context);
                Navigator.of(dialogContext).pop();

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  barrierColor: AppColors.backgroundColor(context),
                  builder: (BuildContext context) {
                    return Scaffold(
                      backgroundColor: AppColors.backgroundColor(context),
                      body: Center(
                        child: Container(
                          width: 280,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor(context),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(40),
                                blurRadius: 30,
                                spreadRadius: 2,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Contenedor circular con gradiente y borde
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primaryColor(
                                      context,
                                    ).withAlpha(60),
                                    width: 2,
                                  ),
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.primaryColor(
                                        context,
                                      ).withAlpha(30),
                                      AppColors.primaryColor(
                                        context,
                                      ).withAlpha(10),
                                    ],
                                    center: Alignment.center,
                                    radius: 0.7,
                                  ),
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryColor(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Texto principal
                              Text(
                                'Cerrando sesión',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textColor(context),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Texto secundario
                              Text(
                                'Su sesión se está cerrando de forma segura',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textColor(
                                    context,
                                  ).withAlpha(180),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
                await authViewModel.signOut(context);
                if (!navigator.mounted) return;
                navigator.pop();
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
}
