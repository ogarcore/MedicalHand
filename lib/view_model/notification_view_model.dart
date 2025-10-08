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

  Future<void> loadNotifications(String userId) async {
    _isLoading = true;
    notifyListeners();

    _notifications = await NotificationStorageService.getNotifications(userId);
    _isLoading = false;
    notifyListeners();
  }

Future<void> markAllAsRead(String userId) async {
  for (var notification in _notifications) {
    notification.isRead = true;
  }
  notifyListeners(); 
  await NotificationStorageService.markAllAsRead(userId);
}

  Future<void> clearAll(String userId) async {
  _notifications = [];
  notifyListeners();
  await NotificationStorageService.clearNotifications(userId);
}

  void clearDataOnSignOut() {
    _notifications = [];
    notifyListeners();
  }
}
