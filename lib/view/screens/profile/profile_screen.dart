import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/user_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

// Importa los nuevos widgets que hemos creado
import 'widgets/profile_content_view.dart';
import 'widgets/profile_loading_indicator.dart';
import 'widgets/profile_error_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.8,
          ),
        ),
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textColor(context)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              HugeIcons.strokeRoundedUserCircle02,
              color: AppColors.primaryColor(context),
              size: 24,
            ),
          ),
        ],
      ),
      body: Consumer<UserViewModel>(
        builder: (context, userViewModel, child) {
          // Estado 1: Cargando y no hay datos previos
          if (userViewModel.isLoading && userViewModel.currentUser == null) {
            return const ProfileLoadingIndicator();
          }

          final UserModel? user = userViewModel.currentUser;
          
          // Estado 2: Error o no se encontraron datos del usuario
          if (user == null) {
            return const ProfileErrorState();
          }
          
          // Estado 3: Datos cargados, mostrar el contenido del perfil
          return ProfileContentView(user: user);
        },
      ),
    );
  }
}