import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationStorageService {
  static String _getUserKey(String userId) => 'notifications_$userId';

  static Future<void> addNotification(
    String userId,
    NotificationModel notification,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    // 👇 LÍNEA AÑADIDA para recargar los datos antes de escribir.
    await prefs.reload();

    final userKey = _getUserKey(userId);
    final List<String> currentNotifications =
        prefs.getStringList(userKey) ?? [];
    currentNotifications.insert(0, notification.toJson());
    await prefs.setStringList(userKey, currentNotifications);
  }

  static Future<List<NotificationModel>> getNotifications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    // 👇 LÍNEA AÑADIDA para asegurar que se leen los datos más recientes.
    await prefs.reload();

    final userKey = _getUserKey(userId);
    final List<String> notificationStrings = prefs.getStringList(userKey) ?? [];
    return notificationStrings
        .map((str) => NotificationModel.fromJson(str))
        .toList();
  }

  static Future<void> markAllAsRead(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    // 👇 LÍNEA AÑADIDA para trabajar sobre la lista más actualizada.
    await prefs.reload();

    final userKey = _getUserKey(userId);
    final List<String> notificationStrings = prefs.getStringList(userKey) ?? [];

    // La lógica interna para marcar como leído no cambia.
    final List<NotificationModel> notifications = notificationStrings
        .map((str) => NotificationModel.fromJson(str))
        .toList();

    for (var notification in notifications) {
      notification.isRead = true;
    }

    final List<String> updatedNotifications = notifications
        .map((n) => n.toJson())
        .toList();
    await prefs.setStringList(userKey, updatedNotifications);
  }

  static Future<void> clearNotifications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = _getUserKey(userId);
    await prefs.remove(userKey);
  }
}
