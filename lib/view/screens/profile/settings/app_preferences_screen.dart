// lib/view/screens/profile/settings/app_preferences_screen.dart
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class AppPreferencesScreen extends StatefulWidget {
  const AppPreferencesScreen({super.key});

  @override
  State<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends State<AppPreferencesScreen> {
  String _selectedTheme = 'Sistema';
  double _textScaleFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Preferencias'),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('APARIENCIA'),
            _buildPreferencesCard(
              child: Column(children: [_buildThemeSelector()]),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('ACCESIBILIDAD'),
            _buildPreferencesCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tamaño del Texto',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _textScaleFactor,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    label: '${(_textScaleFactor * 100).toStringAsFixed(0)}%',
                    activeColor: AppColors.primaryColor,
                    inactiveColor: AppColors.primaryColor.withAlpha(20),
                    onChanged: (value) {
                      setState(() {
                        _textScaleFactor = value;
                      });
                    },
                  ),
                  Center(
                    child: Text(
                      'Así se verá el texto en la app.',
                      style: TextStyle(fontSize: 14 * _textScaleFactor),
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
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPreferencesCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: child,
    );
  }

  Widget _buildThemeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['Claro', 'Oscuro', 'Sistema']
          .map(
            (theme) => ChoiceChip(
              label: Text(theme),
              selected: _selectedTheme == theme,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedTheme = theme;
                  });
                }
              },
              selectedColor: AppColors.primaryColor,
              labelStyle: TextStyle(
                color: _selectedTheme == theme
                    ? Colors.white
                    : AppColors.textColor,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: _selectedTheme == theme
                      ? Colors.transparent
                      : Colors.grey.shade300,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
