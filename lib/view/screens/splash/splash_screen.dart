// lib/view/screens/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../view_model/splash_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // Le decimos al ViewModel que inicie el proceso de verificación y navegación
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SplashViewModel>(context, listen: false).checkStatusAndNavigate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Esta pantalla ahora solo se encarga de mostrar la animación de carga.
    // Ya no necesita manejar el estado de error.
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/icono.png',
              width: 120,
              height: 140,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),
            Lottie.asset(
              'assets/animation/loading.json',
              width: 120,
              height: 120,
              delegates: LottieDelegates(
                values: [ValueDelegate.color(const ['**'], value: AppColors.accentColor)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}