import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.textColor(context).withAlpha(20),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        height: 71,
        padding: EdgeInsets.zero,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 12.5,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  HugeIcons.strokeRoundedCalendarUser,
                  "Mis Citas",
                  0,
                ),
                const SizedBox(width: 40), // espacio FAB
                _buildNavItem(
                  context,
                  HugeIcons.strokeRoundedTransactionHistory,
                  "Historial",
                  2,
                ),
              ],
            ),
            Positioned(bottom: 6, child: _buildFabLabel(context)),
          ],
        ),
      ),
    );
  }

  // Este es tu widget original _buildFabLabel
  Widget _buildFabLabel(BuildContext context) {
    final isSelected = currentIndex == 1;
    return GestureDetector(
      onTap: () => onItemTapped(1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Inicio',
            style: TextStyle(
              color: isSelected ? AppColors.primaryColor(context) : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primaryColor(context),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  // Este es tu widget original _buildNavItem
  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    final isSelected = currentIndex == index;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => onItemTapped(index),
        splashColor: AppColors.primaryColor(context).withAlpha(20),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.primaryColor(context)
                    : Colors.grey,
                size: 25,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primaryColor(context)
                      : Colors.grey,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              if (isSelected)
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor(context),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
