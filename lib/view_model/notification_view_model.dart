// lib/view_model/notification_view_model.dart
import 'package:flutter/material.dart';
import 'package:p_hn25/data/models/notification_model.dart';
import 'package:p_hn25/data/network/notification_storage_service.dart';

class NotificationViewModel extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get hasUnreadNotifications => unreadCount > 0;

  // Carga las notificaciones desde el almacenamiento local
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();
    _notifications = await NotificationStorageService.getNotifications();
    _isLoading = false;
    notifyListeners();
  }

  // Marca todas las notificaciones como leídas
  Future<void> markAllAsRead() async {
    await NotificationStorageService.markAllAsRead();
    await loadNotifications(); // Recarga para reflejar los cambios
  }

  // Limpia todas las notificaciones
  Future<void> clearAll() async {
    await NotificationStorageService.clearNotifications();
    await loadNotifications(); // Recarga para reflejar los cambios
  }
}
