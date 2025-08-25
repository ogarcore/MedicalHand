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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryColor, AppColors.primaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/icono.png',
                width: 150,
                height: 130,
                fit: BoxFit.contain,
              ),
              Lottie.asset(
                'assets/animation/loading.json',
                width: 200,
                height: 200,
                repeat: true,
                animate: true,
                delegates: LottieDelegates(
                  values: [
                    ValueDelegate.color(
                      const ['**'], 
                      value:
                          AppColors.accentColor, 
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
