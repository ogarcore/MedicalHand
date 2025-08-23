import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../view_model/splash_view_model.dart';
import '../welcome/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Llamamos a nuestra nueva función de inicialización
    _initializeApp();
  }

  // Creamos una función async separada para manejar la lógica
  void _initializeApp() async {
    final splashViewModel = Provider.of<SplashViewModel>(context, listen: false);
    final navigator = Navigator.of(context);
    await splashViewModel.handleStartupLogic();
    if (mounted) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.medical_services_outlined,
              size: 100,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'MedicalHand',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}