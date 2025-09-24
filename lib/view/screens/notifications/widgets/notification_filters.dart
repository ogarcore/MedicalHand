import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class NotificationFilters extends StatelessWidget {
  final int unreadCount;
  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onFilterSelected;

  const NotificationFilters({
    super.key,
    required this.unreadCount,
    required this.filters,
    required this.selectedIndex,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor(context).withAlpha(229),
                    AppColors.primaryColor(context).withAlpha(178),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                unreadCount == 0
                    ? 'No hay nuevas notificaciones'
                    : unreadCount == 1
                    ? '1 nueva notificación'
                    : '$unreadCount nuevas notificaciones',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
        Container(
          height: 46,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey[300]!, width: 0.8),
          ),
          child: Row(
            children: List.generate(filters.length, (index) {
              final isSelected = index == selectedIndex;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3.0,
                    vertical: 3,
                  ),
                  child: Stack(
                    children: [
                      // Fondo con efecto de acento suave
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.fastOutSlowIn,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor(context)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                          gradient: isSelected
                              ? LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.primaryColor(context),
                                    AppColors.primaryColor(
                                      context,
                                    ).withAlpha(210),
                                  ],
                                )
                              : null,
                        ),
                      ),
                      // Texto con efecto de elevación suave
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(11),
                          onTap: () => onFilterSelected(index),
                          splashColor: AppColors.primaryColor(
                            context,
                          ).withAlpha(30),
                          highlightColor: AppColors.primaryColor(
                            context,
                          ).withAlpha(40),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11),
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.white.withAlpha(200),
                                      width: 0.8,
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 250),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 13.5,
                                  letterSpacing: isSelected ? 0.2 : 0.0,
                                ),
                                child: Text(filters[index]),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
