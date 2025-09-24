import 'package:flutter/material.dart';
import 'custom_theme_colors.dart';

class AppColors {
  static CustomThemeColors _get(BuildContext context) =>
      Theme.of(context).extension<CustomThemeColors>()!;

  static Color primaryColor(BuildContext context) =>
      _get(context).primaryColor!;

  static Color backgroundColor(BuildContext context) =>
      _get(context).backgroundColor!;

  static Color accentColor(BuildContext context) => _get(context).accentColor!;

  static Color secondaryColor(BuildContext context) =>
      _get(context).secondaryColor!;

  static Color warningColor(BuildContext context) =>
      _get(context).warningColor!;

  static Color successColor(BuildContext context) =>
      _get(context).successColor!;

  static Color textColor(BuildContext context) => _get(context).textColor!;

  static Color textLightColor(BuildContext context) =>
      _get(context).textLightColor!;

  static Color graceColor(BuildContext context) => _get(context).graceColor!;
}
