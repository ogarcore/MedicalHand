import 'package:flutter/material.dart';
import 'custom_theme_colors.dart';

class AppTheme {
  final String name;
  final ThemeData data;
  const AppTheme(this.name, this.data);
}

class AppThemes {
  // 1. TEMA MENTA (Tu tema original)
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
        graceColor: Color(0xFFFFB74D),
      ),
    ],
  );

  // 2. TEMA SERENO (Nueva paleta azul)
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

  // 3. TEMA CÁLIDO (Nueva paleta terracota)
  static final ThemeData calidoTheme = ThemeData(
    brightness: Brightness.light,
    extensions: const <ThemeExtension<dynamic>>[
      CustomThemeColors(
        primaryColor: Color(0xFFFFAB91),
        backgroundColor: Color(0xFFFFF3E0),
        accentColor: Color(0xFF8D6E63),
        secondaryColor: Color(0xFFBCAAA4),
        warningColor: Color(0xFFE57373),
        successColor: Color(0xFFA5D6A7),
        textColor: Color(0xFF333333),
        textLightColor: Color(0xFF757575),
        graceColor: Color(0xFFFFCC80),
      ),
    ],
  );

  static final List<AppTheme> themes = [
    AppTheme('Menta Fresca', mentaTheme),
    AppTheme('Azul Sereno', serenoTheme),
    AppTheme('Coral Suave', calidoTheme),
  ];
}
