import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';

class NotificationFooter extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onMarkAllAsRead;
  final VoidCallback onClearAll;

  const NotificationFooter({
    super.key,
    required this.unreadCount,
    required this.onMarkAllAsRead,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final bool canMarkAsRead = unreadCount > 0;
    final primaryColor = AppColors.primaryColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Botón Marcar como leídas
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: canMarkAsRead
                    ? LinearGradient(
                        colors: [
                          Colors.grey.shade50,
                          Colors.grey.shade100,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: canMarkAsRead 
                    ? Colors.grey.shade300 
                    : Colors.grey.shade200,
                  width: 1.5,
                ),
                boxShadow: canMarkAsRead
                    ? [
                        BoxShadow(
                          color: Colors.black.withAlpha(13),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: canMarkAsRead ? onMarkAllAsRead : null,
                  borderRadius: BorderRadius.circular(14),
                  splashColor: primaryColor.withAlpha(26),
                  highlightColor: primaryColor.withAlpha(13),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: canMarkAsRead 
                            ? Colors.grey.shade700 
                            : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'marcar_ledas'.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: canMarkAsRead 
                              ? Colors.grey.shade700 
                              : Colors.grey.shade400,
                            fontSize: 14,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Botón Limpiar todo
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    Color.lerp(primaryColor, Colors.blue.shade600, 0.4)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withAlpha(77),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: primaryColor.withAlpha(51),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: onClearAll,
                  borderRadius: BorderRadius.circular(14),
                  splashColor: Colors.white.withAlpha(51),
                  highlightColor: Colors.white.withAlpha(26),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'limpiar_todo'.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 14,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}