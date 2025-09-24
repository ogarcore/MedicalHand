// lib/view/screens/notifications/widgets/notification_tile.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:p_hn25/data/models/notification_model.dart';

class NotificationTile extends StatefulWidget {
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

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  bool _isExpanded = false;

  String _formatTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(widget.notification.receivedAt);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else {
      return DateFormat(
        'd MMM',
        'es_ES',
      ).format(widget.notification.receivedAt);
    }
  }

  bool get _needsExpansion {
    return widget.notification.body.length > 90;
  }

  @override
  Widget build(BuildContext context) {
    const animationDuration = Duration(milliseconds: 300);
    const animationCurve = Curves.fastOutSlowIn;

    return GestureDetector(
      onTap: () {
        if (_needsExpansion) {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        }
      },
      child: AnimatedContainer(
        duration: animationDuration,
        curve: animationCurve,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(_isExpanded ? 15 : 10),
              blurRadius: _isExpanded ? 10 : 8,
              offset: Offset(0, _isExpanded ? 3 : 2),
            ),
          ],
          border: widget.isRead
              ? Border.all(color: widget.iconColor.withAlpha(70), width: 1)
              : Border.all(color: widget.iconColor.withAlpha(64), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isRead) ...[
              AnimatedContainer(
                duration: animationDuration,
                curve: animationCurve,
                width: 4,
                height: (_needsExpansion && _isExpanded) ? 70 : 45,
                decoration: BoxDecoration(
                  color: widget.iconColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
            ],
            // Icono principal
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.iconColor.withAlpha(40),
                    widget.iconColor.withAlpha(25),
                  ],
                ),
              ),
              child: Icon(widget.icon, color: widget.iconColor, size: 16),
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
                          widget.notification.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.grey[800],
                            letterSpacing: -0.15,
                            height: 1.2,
                          ),
                          maxLines: 2,
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
                  AnimatedCrossFade(
                    duration: animationDuration,
                    sizeCurve: animationCurve,
                    crossFadeState: _isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    alignment: Alignment.topLeft,
                    firstChild: Text(
                      widget.notification.body,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    secondChild: Text(
                      widget.notification.body,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_needsExpansion) ...[
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0.0,
                duration: animationDuration,
                child: Icon(
                  HugeIcons.strokeRoundedArrowDown01,
                  size: 20,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
