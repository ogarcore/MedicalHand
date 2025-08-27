import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../view_model/splash_view_model.dart';
import '../home/home_screen.dart';
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
    _initializeApp();
  }

  void _initializeApp() async {
    final splashViewModel = Provider.of<SplashViewModel>(
      context,
      listen: false,
    );

    final String route = await splashViewModel.checkUserStatus();

    if (mounted) {
      if (route == 'HOME') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor, // Fondo verde sólido
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/icono.png',
              width: 160,
              height: 140,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 40),

            // Loader animado
            Lottie.asset(
              'assets/animation/loading.json',
              width: 120,
              height: 120,
              repeat: true,
              animate: true,
              delegates: LottieDelegates(
                values: [
                  ValueDelegate.color(
                    const ['**'],
                    value: AppColors.accentColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Texto minimalista
            const Text(
              "Cargando...",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
