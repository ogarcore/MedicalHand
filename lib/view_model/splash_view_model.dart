// lib/view_model/splash_view_model.dart
import 'dart:async'; // Necesario para manejo de errores de red
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:p_hn25/view_model/notification_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import '../view/screens/home/home_screen.dart';
import '../view/screens/splash/no_internet_screen.dart';
import '../view/screens/welcome/welcome_screen.dart';
import 'package:p_hn25/data/network/notification_service.dart';

class SplashViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService.instance;

  Future<void> checkStatusAndNavigate(
    BuildContext context, {
    required UserViewModel userViewModel,
    required NotificationViewModel notificationViewModel,
  }) async {
    if (!context.mounted) return;
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NoInternetScreen()),
        );
      }
      return; 
    }
    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      final dataFetchFuture = userViewModel.fetchCurrentUser();

      try {
        await dataFetchFuture;

        await _notificationService.initNotifications(
          userViewModel: userViewModel,
          notificationViewModel: notificationViewModel,
        );

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const NoInternetScreen()),
          );
        }
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 1300));
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    }
  }
}
