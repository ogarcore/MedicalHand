// lib/view_model/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = AppThemes.mentaTheme;
  ThemeData get currentTheme => _currentTheme;

  String _currentThemeName = 'Menta Fresca';
  String get currentThemeName => _currentThemeName;

  ThemeProvider() {
    // CAMBIO CLAVE: Se vuelve a llamar la función de carga aquí.
    // Esto asegura que al abrir la app, siempre se intente cargar el tema del usuario.
    loadUserTheme();
  }

  void setTheme(AppTheme theme) async {
    if (_currentTheme != theme.data) {
      _currentTheme = theme.data;
      _currentThemeName = theme.name;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await prefs.setString('theme_$userId', theme.name);
      }
    }
  }

  Future<void> loadUserTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    String themeName = 'Menta Fresca'; // Valor por defecto si no hay usuario

    if (userId != null) {
      // Si hay un usuario, busca su tema guardado
      themeName = prefs.getString('theme_$userId') ?? 'Menta Fresca';
    }

    final theme = AppThemes.themes.firstWhere(
      (t) => t.name == themeName,
      orElse: () => AppThemes.themes.first,
    );

    _currentTheme = theme.data;
    _currentThemeName = theme.name;
    notifyListeners();
  }

  void resetToDefault() {
    _currentTheme = AppThemes.mentaTheme;
    _currentThemeName = 'Menta Fresca';
    notifyListeners();
  }
}
