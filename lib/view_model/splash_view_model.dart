// lib/view_model/splash_view_model.dart
import 'dart:async'; // Necesario para manejo de errores de red
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import '../view/screens/home/home_screen.dart';
import '../view/screens/splash/no_internet_screen.dart';
import '../view/screens/welcome/welcome_screen.dart';
import 'package:p_hn25/data/network/notification_service.dart';

class SplashViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  Future<void> checkStatusAndNavigate(
    BuildContext context, {
    required UserViewModel userViewModel,
  }) async {
    if (!context.mounted) return;

    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      final dataFetchFuture = userViewModel.fetchCurrentUser();
      final minSplashTimeFuture = Future.delayed(
        const Duration(milliseconds: 1500),
      ); // 1.5 segundos

      try {
        // Future.wait espera a que AMBAS tareas terminen.
        await Future.wait([dataFetchFuture, minSplashTimeFuture]);

        await _notificationService.initNotifications(userViewModel);

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } catch (e) {
        print("Error al cargar datos en splash: $e");
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const NoInternetScreen()),
          );
        }
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    }
  }
}
