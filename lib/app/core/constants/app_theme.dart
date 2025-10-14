// lib/app/core/constants/app_theme.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'custom_theme_colors.dart';

class AppTheme {
  final String keyName; // Clave de traducción (ej. 'menta_fresca')
  final ThemeData data;

  const AppTheme(this.keyName, this.data);

  /// Devuelve el nombre traducido según el idioma actual
  String getTranslatedName() => keyName.tr();
}

class AppThemes {
  // 🌿 TEMA MENTA
  static final ThemeData mentaTheme = ThemeData(
    brightness: Brightness.light,
    extensions: const <ThemeExtension<dynamic>>[
      CustomThemeColors(
        primaryColor: Color(0xFF81C784),
        backgroundColor: Color(0xFFF0F7F4),
        accentColor: Color(0xFF26A69A),
        secondaryColor: Color(0xFF4CAF50),
        warningColor: Color(0xFFE76F51),
        successColor: Color(0xFF2E7D32),
        textColor: Color(0xFF333333),
        textLightColor: Color(0xFF757575),
        graceColor: Color(0xFFFFB85C),
      ),
    ],
  );

  // 🌊 TEMA SERENO
  static final ThemeData serenoTheme = ThemeData(
    brightness: Brightness.light,
    extensions: const <ThemeExtension<dynamic>>[
      CustomThemeColors(
        primaryColor: Color(0xFF64B5F6),
        backgroundColor: Color(0xFFE3F2FD),
        accentColor: Color(0xFF4DB6AC),
        secondaryColor: Color(0xFF4DD0E1),
        warningColor: Color(0xFFE57373),
        successColor: Color(0xFF81C784),
        textColor: Color(0xFF333333),
        textLightColor: Color(0xFF757575),
        graceColor: Color(0xFFFFD54F),
      ),
    ],
  );

  // 💜 LAVANDA
  static final ThemeData lavandaTheme = ThemeData(
    brightness: Brightness.light,
    extensions: const <ThemeExtension<dynamic>>[
      CustomThemeColors(
        primaryColor: Color(0xFF7E57C2),
        backgroundColor: Color(0xFFF3F2F8),
        accentColor: Color(0xFF00897B),
        secondaryColor: Color(0xFF90A4AE),
        warningColor: Color(0xFFFF8A65),
        successColor: Color(0xFF4DB6AC),
        textColor: Color(0xFF37474F),
        textLightColor: Color(0xFF78909C),
        graceColor: Color(0xFFFFD54F),
      ),
    ],
  );

  /// Lista de temas disponibles
  static final List<AppTheme> themes = [
    AppTheme('menta_fresca', mentaTheme),
    AppTheme('azul_sereno', serenoTheme),
    AppTheme('lavanda_suave', lavandaTheme),
  ];
}
