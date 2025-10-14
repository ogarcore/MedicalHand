import 'package:easy_localization/easy_localization.dart';
// lib/view/screens/notifications/widgets/notification_list.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/notification_model.dart';

import 'notification_shimmer.dart';
import 'notification_tile.dart';

class NotificationList extends StatelessWidget {
  final bool isLoading;
  final List<NotificationModel> notifications;

  const NotificationList({
    super.key,
    required this.isLoading,
    required this.notifications,
  });

  Map<String, dynamic> _getNotificationStyle(
    BuildContext context,
    String type,
  ) {
    switch (type) {
      case 'cita_confirmada':
        return {
          'icon': HugeIcons.strokeRoundedCheckmarkCircle02,
          'color': AppColors.successColor(context),
        };
      case 'solicitud_recibida':
        return {
          'icon': HugeIcons.strokeRoundedSent,
          'color': AppColors.accentColor(context),
        };
      case 'recordatorio':
        return {
          'icon': HugeIcons.strokeRoundedAlarmClock,
          'color': AppColors.warningColor(context),
        };
      default:
        return {
          'icon': HugeIcons.strokeRoundedNotification01,
          'color': AppColors.primaryColor(context),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const NotificationShimmer();
    }

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              HugeIcons.strokeRoundedNotificationOff03,
              size: 48,
              color: AppColors.textLightColor(context),
            ),
            SizedBox(height: 16),
            Text(
              'todo_est_en_calma'.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor(context),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'no_tienes_notificaciones_nuevas'.tr(),
              style: TextStyle(color: AppColors.textLightColor(context)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      cacheExtent: 500,
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final style = _getNotificationStyle(context, notification.type);
        return NotificationTile(
          notification: notification,
          icon: style['icon'] as IconData,
          iconColor: style['color'] as Color,
          isRead: notification.isRead,
        );
      },
    );
  }
}
