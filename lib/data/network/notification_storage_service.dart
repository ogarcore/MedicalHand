// lib/data/services/notification_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationStorageService {
  static const _key = 'notifications';

  // Guarda una nueva notificación en la lista
  static Future<void> addNotification(NotificationModel notification) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentNotifications = prefs.getStringList(_key) ?? [];
    currentNotifications.insert(0, notification.toJson());
    await prefs.setStringList(_key, currentNotifications);
  }

  // Obtiene todas las notificaciones guardadas
  static Future<List<NotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> notificationStrings = prefs.getStringList(_key) ?? [];
    return notificationStrings
        .map((str) => NotificationModel.fromJson(str))
        .toList();
  }

  // CAMBIO: Añadido el método que faltaba para marcar todas como leídas
  static Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> notificationStrings = prefs.getStringList(_key) ?? [];

    // Convertimos las notificaciones de texto a objetos
    final List<NotificationModel> notifications = notificationStrings
        .map((str) => NotificationModel.fromJson(str))
        .toList();

    // Marcamos cada una como leída
    for (var notification in notifications) {
      notification.isRead = true;
    }

    // Volvemos a guardar la lista actualizada como texto
    final List<String> updatedNotifications = notifications
        .map((n) => n.toJson())
        .toList();
    await prefs.setStringList(_key, updatedNotifications);
  }

  // Limpia todas las notificaciones
  static Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
