// lib/view_model/splash_view_model.dart
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:p_hn25/view_model/user_view_model.dart'; // CAMBIO: Importamos el UserViewModel
import '../view/screens/home/home_screen.dart';
import '../view/screens/splash/no_internet_screen.dart';
import '../view/screens/welcome/welcome_screen.dart';

class SplashViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }

    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> checkStatusAndNavigate(
    BuildContext context, {
    required UserViewModel userViewModel,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;

    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      bool hasInternet = await _hasInternetConnection();

      if (!context.mounted) return;

      if (hasInternet) {
        await userViewModel.fetchCurrentUser();

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NoInternetScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }
}
