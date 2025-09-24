// lib/view/screens/profile/settings/app_preferences_screen.dart
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/constants/app_theme.dart';
import 'package:p_hn25/app/core/constants/custom_theme_colors.dart';
import 'package:p_hn25/view_model/theme_provider.dart';
import 'package:provider/provider.dart';

class AppPreferencesScreen extends StatefulWidget {
  const AppPreferencesScreen({super.key});

  @override
  State<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends State<AppPreferencesScreen> {
  double _textScaleFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: const Text('Preferencias'),
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('PALETA DE COLORES'),
            _buildPreferencesCard(
              context,
              child: Column(
                children: AppThemes.themes.map((appTheme) {
                  return _ThemeOption(
                    theme: appTheme,
                    isSelected: themeProvider.currentThemeName == appTheme.name,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('ACCESIBILIDAD'),
            _buildPreferencesCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Tamaño del Texto',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _textScaleFactor,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    label: '${(_textScaleFactor * 100).toStringAsFixed(0)}%',
                    activeColor: AppColors.primaryColor(context),
                    inactiveColor: AppColors.primaryColor(
                      context,
                    ).withAlpha(50),
                    onChanged: (value) {
                      setState(() {
                        _textScaleFactor = value;
                      });
                    },
                  ),
                  Center(
                    child: Text(
                      'Así se verá el texto en la app.',
                      style: TextStyle(
                        fontSize: 14 * _textScaleFactor,
                        color: AppColors.textLightColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textLightColor(context),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor(context).withAlpha(50),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final AppTheme theme;
  final bool isSelected;

  const _ThemeOption({required this.theme, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    // Extraemos los colores específicos de la paleta de esta opción, no del tema global
    final optionColors = theme.data.extension<CustomThemeColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: isSelected
            ? optionColors.primaryColor!.withAlpha(25)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => themeProvider.setTheme(theme),
          borderRadius: BorderRadius.circular(12),
          splashColor: optionColors.primaryColor!.withAlpha(40),
          highlightColor: optionColors.primaryColor!.withAlpha(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? optionColors.primaryColor!
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        optionColors.primaryColor!,
                        optionColors.secondaryColor!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    theme.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor(context),
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: optionColors.primaryColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
