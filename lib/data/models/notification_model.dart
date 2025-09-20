// lib/data/models/notification_model.dart
import 'dart:convert';

class NotificationModel {
  final String title;
  final String body;
  final DateTime receivedAt;
  bool isRead;
  final String type;

  NotificationModel({
    required this.title,
    required this.body,
    required this.receivedAt,
    this.isRead = false,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'receivedAt': receivedAt.toIso8601String(),
      'isRead': isRead,
      'type': type,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      receivedAt: DateTime.parse(map['receivedAt']),
      isRead: map['isRead'] ?? false,
      type: map['type'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source));
}
