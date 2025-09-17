import 'package:flutter/material.dart';
import 'package:p_hn25/view_model/notification_view_model.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../../app/core/constants/app_colors.dart';
import '../../../view_model/splash_view_model.dart';
import '../../../view_model/user_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final splashViewModel = Provider.of<SplashViewModel>(
        context,
        listen: false,
      );
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final notificationViewModel = Provider.of<NotificationViewModel>(
        context,
        listen: false,
      );

      splashViewModel.checkStatusAndNavigate(
        context,
        userViewModel: userViewModel,
        notificationViewModel: notificationViewModel,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
                values: [
                  ValueDelegate.color(const [
                    '**',
                  ], value: AppColors.accentColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
