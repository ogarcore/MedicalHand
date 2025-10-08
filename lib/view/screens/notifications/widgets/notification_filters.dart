import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class NotificationFilters extends StatelessWidget {
  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onFilterSelected;

  const NotificationFilters({
    super.key,
    required this.filters,
    required this.selectedIndex,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth - 40; // 20 margin on each side
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            right: 16,
            left: 16,
            top: 6,
            bottom: 16,
          ),
          child: Align(
            alignment: Alignment.centerRight,
          ),
        ),
        Container(
          height: 54,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[800]!.withAlpha(60)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[700]!
                  : Colors.grey[200]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Indicador de selección animado - CORREGIDO
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                left: (selectedIndex * (containerWidth / filters.length)) + 4,
                top: 4,
                bottom: 4,
                child: Container(
                  width: (containerWidth / filters.length) - 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor,
                        Color.lerp(primaryColor, Colors.blue.shade400, 0.3)!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withAlpha(120),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              // Botones
              Row(
                children: List.generate(filters.length, (index) {
                  final isSelected = index == selectedIndex;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 4,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => onFilterSelected(index),
                          splashColor: primaryColor.withAlpha(50),
                          highlightColor: primaryColor.withAlpha(25),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey[300]
                                          : Colors.grey[700],
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  fontSize: 14,
                                  letterSpacing: isSelected ? 0.3 : 0.1,
                                ),
                                child: Text(
                                  filters[index],
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}