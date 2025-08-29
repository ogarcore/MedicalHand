// lib/view_model/splash_view_model.dart
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../view/screens/home/home_screen.dart';
import '../view/screens/splash/no_internet_screen.dart';
import '../view/screens/welcome/welcome_screen.dart';

class SplashViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Revisa si hay internet de forma confiable.
  Future<bool> _hasInternetConnection() async {
    // Primero, revisa si está conectado a una red (WiFi o Datos)
    final connectivityResult = await Connectivity().checkConnectivity();
// Ahora devuelve una lista, así que revisamos si contiene "none"
if (connectivityResult.contains(ConnectivityResult.none)) {
  return false;
}
    
    // Si está conectado, hace una segunda prueba para ver si de verdad hay acceso a internet.
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false; // Si no puede conectar con google.com, no hay internet.
    }
  }

  /// Verifica el estado del usuario y NAVEGA a la pantalla correcta.
  Future<void> checkStatusAndNavigate(BuildContext context) async {
    // Pequeña pausa para que se vea la animación
    await Future.delayed(const Duration(seconds: 2));

    final currentUser = _auth.currentUser;

    // --- ESTA ES LA LÓGICA CLAVE ---
    if (currentUser != null) {
      // 1. Si el usuario SÍ está logueado, revisa la conexión
      bool hasInternet = await _hasInternetConnection();
      if (hasInternet) {
        // Si hay internet, va a Home
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        // Si no hay internet, va a la pantalla de error
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NoInternetScreen()));
      }
    } else {
      // 2. Si el usuario NO está logueado, va directo a Welcome SIN revisar internet
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()));
    }
  }
}