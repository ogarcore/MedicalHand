// lib/view/screens/home/widgets/notification_tile.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:p_hn25/data/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final IconData icon;
  final Color iconColor;
  final bool isRead;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
  });

  String _formatTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(notification.receivedAt);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else {
      return DateFormat('d MMM', 'es_ES').format(notification.receivedAt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isRead
            ? Border.all(color: Colors.grey.shade100, width: 1)
            : Border.all(color: iconColor.withAlpha(64), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isRead) ...[
            Container(
              width: 4,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(31),
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [iconColor.withAlpha(38), iconColor.withAlpha(20)],
              ),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.grey[800],
                          letterSpacing: -0.15,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTimeAgo(),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
