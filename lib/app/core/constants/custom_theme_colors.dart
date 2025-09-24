// lib/app/core/constants/custom_theme_colors.dart
import 'package:flutter/material.dart';

// Esta clase define los nombres de nuestros colores personalizados
class CustomThemeColors extends ThemeExtension<CustomThemeColors> {
  final Color? primaryColor;
  final Color? backgroundColor;
  final Color? accentColor;
  final Color? secondaryColor;
  final Color? warningColor;
  final Color? successColor;
  final Color? textColor;
  final Color? textLightColor;
  final Color? graceColor;

  const CustomThemeColors({
    required this.primaryColor,
    required this.backgroundColor,
    required this.accentColor,
    required this.secondaryColor,
    required this.warningColor,
    required this.successColor,
    required this.textColor,
    required this.textLightColor,
    required this.graceColor,
  });

  // Flutter usa esto para las transiciones de tema
  @override
  ThemeExtension<CustomThemeColors> lerp(
    ThemeExtension<CustomThemeColors>? other,
    double t,
  ) {
    if (other is! CustomThemeColors) {
      return this;
    }
    return CustomThemeColors(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      accentColor: Color.lerp(accentColor, other.accentColor, t),
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t),
      warningColor: Color.lerp(warningColor, other.warningColor, t),
      successColor: Color.lerp(successColor, other.successColor, t),
      textColor: Color.lerp(textColor, other.textColor, t),
      textLightColor: Color.lerp(textLightColor, other.textLightColor, t),
      graceColor: Color.lerp(graceColor, other.graceColor, t),
    );
  }

  // Flutter usa esto internamente, no necesitas preocuparte por ello
  @override
  CustomThemeColors copyWith({
    Color? primaryColor,
    Color? backgroundColor,
    Color? accentColor,
    Color? secondaryColor,
    Color? warningColor,
    Color? successColor,
    Color? textColor,
    Color? textLightColor,
    Color? graceColor,
  }) {
    return CustomThemeColors(
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      accentColor: accentColor ?? this.accentColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      warningColor: warningColor ?? this.warningColor,
      successColor: successColor ?? this.successColor,
      textColor: textColor ?? this.textColor,
      textLightColor: textLightColor ?? this.textLightColor,
      graceColor: graceColor ?? this.graceColor,
    );
  }
}
