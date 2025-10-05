// lib/view/screens/home/widgets/health_tips_section.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class HealthTipsSection extends StatelessWidget {
  const HealthTipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> healthTips = [
      {
        'icon': HugeIcons.strokeRoundedWaterfallUp01,
        'title': 'Mantente Hidratado',
        'subtitle': 'Beber suficiente agua es vital para tu energía y salud general.',
      },
      {
        'icon': HugeIcons.strokeRoundedWorkoutRun,
        'title': 'Activa tu Cuerpo',
        'subtitle': 'Una caminata diaria de 30 minutos mejora tu salud cardiovascular.',
      },
      {
        'icon': HugeIcons.strokeRoundedHealth,
        'title': 'La Prevención es Clave',
        'subtitle': 'No olvides tu chequeo médico anual para una detección temprana.',
      },
      {
        'icon': HugeIcons.strokeRoundedMoon01,
        'title': 'Descansa y Recupérate',
        'subtitle': 'Dormir entre 7-8 horas fortalece tu sistema inmune y mejora tu ánimo.',
      },
      {
        'icon': HugeIcons.strokeRoundedApple,
        'title': 'Come Frutas y Verduras',
        'subtitle': 'Añaden vitaminas, minerales y fibra esencial a tu dieta diaria.',
      },
    ];

    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final tipOfTheDay = healthTips[dayOfYear % healthTips.length];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          _CompactHealthTipCard(
            icon: tipOfTheDay['icon'],
            title: tipOfTheDay['title'],
            subtitle: tipOfTheDay['subtitle'],
          ),
        ],
      ),
    );
  }
}

class _CompactHealthTipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CompactHealthTipCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono compacto
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    Color.lerp(primaryColor, Colors.blue.shade600, 0.4)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Contenido compacto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge y título en línea
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              HugeIcons.strokeRoundedIdea,
                              size: 11,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Consejo del Día',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor(context),
                      height: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textLightColor(context),
                      height: 1.3,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Footer minimalista
                  Row(
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedIdea,
                        size: 12,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Actualizado diariamente',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}