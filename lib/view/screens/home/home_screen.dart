import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_model/auth_view_model.dart';
import '../welcome/welcome_screen.dart';
import '../../../app/core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textColor),
            onPressed: () async {
              await authViewModel.signOut();
              
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          '¡Bienvenido a MedicalHand!',
          style: TextStyle(fontSize: 24, color: AppColors.textColor),
        ),
      ),
    );
  }
}