// lib/view_model/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = AppThemes.mentaTheme;
  ThemeData get currentTheme => _currentTheme;

  String _currentThemeKey = 'menta_fresca';
  String get currentThemeKey => _currentThemeKey;

  /// Devuelve el nombre traducido del tema actual (ya listo para mostrar)
  String get currentThemeTranslatedName =>
      AppThemes.themes.firstWhere(
        (t) => t.keyName == _currentThemeKey,
        orElse: () => AppThemes.themes.first,
      ).getTranslatedName();

  ThemeProvider() {
    // Al inicializar, cargamos el tema guardado del usuario
    loadUserTheme();
  }

  /// Cambia el tema actual y lo guarda en preferencias (por usuario)
  Future<void> setTheme(AppTheme theme) async {
    if (_currentTheme != theme.data) {
      _currentTheme = theme.data;
      _currentThemeKey = theme.keyName;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        await prefs.setString('theme_$userId', theme.keyName);
      } else {
        await prefs.setString('theme_default', theme.keyName);
      }
    }
  }

  /// Carga el tema guardado del usuario (o el predeterminado si no hay)
  Future<void> loadUserTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    String savedThemeKey =
        (userId != null) ? prefs.getString('theme_$userId') ?? '' : prefs.getString('theme_default') ?? '';

    // Si no hay tema guardado, usa el predeterminado
    if (savedThemeKey.isEmpty) {
      savedThemeKey = 'menta_fresca';
    }

    // Buscar el tema que coincida con la clave guardada
    final theme = AppThemes.themes.firstWhere(
      (t) => t.keyName == savedThemeKey,
      orElse: () => AppThemes.themes.first,
    );

    _currentTheme = theme.data;
    _currentThemeKey = theme.keyName;
    notifyListeners();
  }

  /// Restaura el tema por defecto (menta fresca)
  Future<void> resetToDefault() async {
    _currentTheme = AppThemes.mentaTheme;
    _currentThemeKey = 'menta_fresca';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await prefs.setString('theme_$userId', _currentThemeKey);
    } else {
      await prefs.setString('theme_default', _currentThemeKey);
    }
  }
}
