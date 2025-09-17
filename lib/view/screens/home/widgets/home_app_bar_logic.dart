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
import 'package:p_hn25/view_model/appointment_view_model.dart';
import 'package:p_hn25/view_model/auth_view_model.dart';
import 'package:p_hn25/view_model/family_view_model.dart';
import 'package:p_hn25/view_model/notification_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'notifications_panel.dart';

mixin HomeAppBarLogic on State<HomeAppBar> {
  bool isMenuOpen = false;
  final GlobalKey profileButtonKey = GlobalKey();

  String _getShortName(UserModel user) {
    final firstName = (user.firstName).split(' ').first;
    final lastName = (user.lastName).split(' ').first;
    return '$firstName $lastName'.trim();
  }

  void showNotificationsPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return GestureDetector(
          onTap: () {},
          child: NotificationsPanel(
            onClose: () {
              Navigator.of(context).pop();
            },
          ),
        );
      },
    ).then((_) {
      Provider.of<NotificationViewModel>(
        context,
        listen: false,
      ).loadNotifications();
    });
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
                      ? AppColors.secondaryColor
                      : AppColors.textColor,
                ),
              ),
            ),
            const SizedBox(width: 4),
            if (isSelected)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryColor,
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
          AppColors.primaryColor,
        ),
      );
    }
    menuItems.add(
      _buildNavigationMenuItem(
        'family',
        'Mis Familiares',
        HugeIcons.strokeRoundedUserGroup02,
        AppColors.accentColor,
      ),
    );
    menuItems.add(
      _buildNavigationMenuItem(
        'support',
        'Soporte',
        HugeIcons.strokeRoundedCustomerService01,
        AppColors.textColor,
      ),
    );
    menuItems.add(const PopupMenuDivider());
    menuItems.add(
      _buildNavigationMenuItem(
        'logout',
        'Cerrar Sesión',
        HugeIcons.strokeRoundedLogout03,
        AppColors.warningColor,
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
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final appointmentViewModel = Provider.of<AppointmentViewModel>(
      context,
      listen: false,
    );
    final familyViewModel = Provider.of<FamilyViewModel>(
      context,
      listen: false,
    );

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

                // Aquí personalizamos el modal de "cerrando sesión..."
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Cerrando sesión…',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

                userViewModel.clearUser();
                appointmentViewModel.disposeListeners();
                familyViewModel.clearData();
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
