// lib/view/screens/profile/settings/app_preferences_screen.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/app/core/constants/app_theme.dart';
import 'package:p_hn25/app/core/constants/custom_theme_colors.dart';
import 'package:p_hn25/view_model/theme_provider.dart';

class AppPreferencesScreen extends StatefulWidget {
  const AppPreferencesScreen({super.key});

  @override
  State<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends State<AppPreferencesScreen> {
  /// Idiomas disponibles
  final Map<String, Locale> _allLanguages = {
    'Español': const Locale('es'),
    'Inglés': const Locale('en'),
    'Miskito': const Locale('miq'),
  };

  /// Traducciones para mostrar los nombres correctamente según el idioma activo
  String _getLanguageDisplayName(String languageKey) {
    switch (languageKey) {
      case 'Español':
        return {
          'es': 'Español',
          'en': 'Spanish',
          'miq': 'Spayanka',
        }[context.locale.languageCode]!;
      case 'Inglés':
        return {
          'es': 'Inglés',
          'en': 'English',
          'miq': 'Ingliska',
        }[context.locale.languageCode]!;
      case 'Miskito':
        return {
          'es': 'Miskito',
          'en': 'Miskito',
          'miq': 'Miskitu',
        }[context.locale.languageCode]!;
      default:
        return languageKey;
    }
  }

  /// Filtra los idiomas que se mostrarán según el idioma actual
  Map<String, Locale> _getFilteredLanguages(Locale locale) {
    if (locale.languageCode == 'es') {
      return {
        'Español': const Locale('es'),
        'Inglés': const Locale('en'),
      };
    } else if (locale.languageCode == 'miq') {
      return {
        'Miskitu': const Locale('miq'),
        'Inglés': const Locale('en'),
      };
    } else {
      return {
        'English': const Locale('en'),
        'Español': const Locale('es'),
        'Miskito': const Locale('miq'),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentLocale = context.locale;
    final filteredLanguages = _getFilteredLanguages(currentLocale);

    final selectedLanguageKey = _allLanguages.entries
        .firstWhere(
          (entry) => entry.value == currentLocale,
          orElse: () => _allLanguages.entries.first,
        )
        .key;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text('preferencias'.tr()),
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textColor(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('paleta_de_colores'.tr()),
            _buildPreferencesCard(
              context,
              child: Column(
                children: AppThemes.themes.map((appTheme) {
                  return _ThemeOption(
                    theme: appTheme,
                    isSelected:
                        themeProvider.currentThemeKey == appTheme.keyName,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('idioma'.tr()),
            _buildPreferencesCard(
              context,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primaryColor(context).withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            HugeIcons.strokeRoundedLanguageSquare,
                            color: AppColors.primaryColor(context),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'idioma_de_la_aplicacin'.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.textColor(context),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade100,
                      ),
                      child: DropdownButton<String>(
                        value: filteredLanguages.containsKey(selectedLanguageKey)
                            ? selectedLanguageKey
                            : filteredLanguages.keys.first,
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textLightColor(context),
                          size: 20,
                        ),
                        items: filteredLanguages.keys.map((String key) {
                          return DropdownMenuItem<String>(
                            value: key,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                _getLanguageDisplayName(key),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newKey) async {
                          if (newKey != null) {
                            final newLocale = filteredLanguages[newKey];
                            if (newLocale != null) {
                              await context.setLocale(newLocale);
                              if (mounted) setState(() {});
                            }
                          }
                        },
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textLightColor(context),
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(BuildContext context, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.primaryColor(context).withAlpha(40),
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
    final optionColors = theme.data.extension<CustomThemeColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      child: Material(
        color: isSelected
            ? optionColors.primaryColor!.withAlpha(20)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => themeProvider.setTheme(theme),
          borderRadius: BorderRadius.circular(14),
          splashColor: optionColors.primaryColor!.withAlpha(30),
          highlightColor: optionColors.primaryColor!.withAlpha(15),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
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
                  width: 36,
                  height: 36,
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
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    theme.getTranslatedName(), // 🔥 Usa el nombre traducido
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textColor(context),
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: optionColors.primaryColor,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
