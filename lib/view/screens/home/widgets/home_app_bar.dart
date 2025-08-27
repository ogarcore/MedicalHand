import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

// Convertido a StatefulWidget para manejar el estado de la flecha del menú.
class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeAppBarState extends State<HomeAppBar> {
  // Variable de estado para saber si el menú está abierto.
  bool _isMenuOpen = false;
  // GlobalKey para obtener la posición del botón de perfil en la pantalla.
  final GlobalKey _profileButtonKey = GlobalKey();

  /// Muestra un menú emergente anclado al botón de perfil.
  void _showProfileMenu(BuildContext context) {
    // Antes de mostrar el menú, actualizamos el estado para cambiar la flecha a "hacia arriba".
    setState(() {
      _isMenuOpen = true;
    });

    final RenderBox renderBox = _profileButtonKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    // Ancho deseado para el menú desplegable.
    const double menuWidth = 150.0;

    showMenu<String>(
      context: context,
      // Posiciona el menú debajo del botón.
      position: RelativeRect.fromLTRB(
        position.dx - 60, // Alineado a la izquierda del botón.
        position.dy + size.height + 6.0, // Debajo del botón con un espacio de 6px.
        position.dx + size.width, // El borde derecho se calculará para que el ancho sea `menuWidth`.
        position.dy,
      ),
      // Envolvemos los items en un SizedBox para forzar el ancho deseado.
      items: [
        PopupMenuItem(
          enabled: false, // Este item no es seleccionable.
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
              Icon(HugeIcons.strokeRoundedUser, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 12),
              Text('Mi Perfil', style: TextStyle(color: AppColors.primaryColor)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(HugeIcons.strokeRoundedCustomerService01, color: AppColors.textColor.withAlpha(178), size: 20),
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
              Icon(HugeIcons.strokeRoundedLogout03, color: AppColors.warningColor, size: 20),
              const SizedBox(width: 12),
              Text(
                'Cerrar Sesión',
                style: TextStyle(color: AppColors.warningColor, fontWeight: FontWeight.w500),
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
      // Este bloque se ejecuta CUANDO el menú se cierra.
      // Actualizamos el estado para que la flecha vuelva a ser "hacia abajo".
      setState(() {
        _isMenuOpen = false;
      });

      if (selectedValue == null) return;

      if (selectedValue == 'profile') {
        print('Navegando a Mi Perfil...');
      } else if (selectedValue == 'settings') {
        print('Navegando a Soporte...');
      } else if (selectedValue == 'logout') {
        print('Cerrando sesión...');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      title: GestureDetector(
        key: _profileButtonKey,
        onTap: () {
          // Si el menú ya está abierto, no hacemos nada. Si no, lo mostramos.
          if (!_isMenuOpen) {
            _showProfileMenu(context);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  color: AppColors.primaryColor.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  HugeIcons.strokeRoundedUser,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Oliver García',
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              // Anima el cambio entre la flecha hacia abajo y hacia arriba.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Icon(
                  _isMenuOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  key: ValueKey<bool>(_isMenuOpen), // Key para que la animación funcione.
                  color: AppColors.textColor.withAlpha(178),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(25),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  HugeIcons.strokeRoundedNotification03,
                  color: AppColors.textColor.withAlpha(204),
                  size: 24,
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.warningColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}