// lib/view/screens/home/widgets/dashboard_header.dart
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view_model/user_view_model.dart'; // CAMBIO: Importar el ViewModel
import 'package:provider/provider.dart'; // CAMBIO: Importar Provider

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  // Función para obtener saludo según la hora
  String _getGreeting(int hour) {
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        if (userViewModel.isLoading) {
          return const Text("Cargando...");
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '¡$greeting! ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor(context),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '¿Cómo te podemos ayudar hoy?',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        );
      },
    );
  }
}
