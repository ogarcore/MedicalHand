import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Verifica si hay un usuario logueado y decide a dónde navegar.
  Future<String> checkUserStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    if (_auth.currentUser != null) {
      // Si hay un usuario, vamos a la pantalla principal
      return 'HOME';
    } else {
      // Si no hay usuario, vamos a la pantalla de bienvenida
      return 'WELCOME';
    }
  }
}