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
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'notifications_panel.dart';

mixin HomeAppBarLogic on State<HomeAppBar> {
  bool isMenuOpen = false;
  final GlobalKey profileButtonKey = GlobalKey();

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
    );
  }

  // CAMBIO: El método ahora es asíncrono para poder buscar a los familiares
  void showProfileMenu() async {
    setState(() => isMenuOpen = true);

    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final familyViewModel = Provider.of<FamilyViewModel>(
      context,
      listen: false,
    );
    final navigator = Navigator.of(context);

    final currentUser = userViewModel.currentUser;
    if (currentUser == null) return;

    // Buscamos la lista de familiares una sola vez
    final familyMembers = await familyViewModel.getFamilyMembers().first;

    final RenderBox renderBox =
        profileButtonKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    final List<PopupMenuEntry<dynamic>> menuItems = [];

    // 1. Añadimos al usuario principal (el tutor)
    menuItems.add(
      PopupMenuItem<UserModel>(
        value: currentUser,
        child: Text(
          '${currentUser.firstName} (Yo)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );

    // 2. Si hay familiares, los añadimos
    if (familyMembers.isNotEmpty) {
      menuItems.add(const PopupMenuDivider());
      for (var member in familyMembers) {
        menuItems.add(
          PopupMenuItem<UserModel>(
            value: member,
            child: Text(
              '${member.firstName} (${member.medicalInfo?['kinship'] ?? 'Familiar'})',
            ),
          ),
        );
      }
    }

    // 3. Añadimos las opciones de navegación
    menuItems.add(const PopupMenuDivider());
    menuItems.add(
      _buildNavigationMenuItem(
        'profile',
        'Mi Perfil',
        HugeIcons.strokeRoundedUser,
        AppColors.primaryColor,
      ),
    );
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

    const double menuWidth = 210.0;

    showMenu<dynamic>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx - 60,
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

      // Si el valor es un UserModel, es un cambio de perfil
      if (selectedValue is UserModel) {
        userViewModel.changeActiveProfile(selectedValue);
      }
      // Si es un String, es una acción de navegación
      else if (selectedValue is String) {
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

  // Helper para construir los items de navegación del menú
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
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Dialog(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                );

                // Limpieza de todos los ViewModels
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
