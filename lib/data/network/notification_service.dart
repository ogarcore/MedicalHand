// lib/data/network/notification_service.dart
import 'dart:async';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:p_hn25/data/models/notification_model.dart';
import 'package:p_hn25/data/network/notification_storage_service.dart';
import 'package:p_hn25/firebase_options.dart';
import 'package:p_hn25/view_model/notification_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("--- BACKGROUND HANDLER ACTIVADO ---");

  // Imprime todo el contenido del mensaje
  print("Mensaje completo: ${message.toMap()}");
  print("Contenido de 'notification': ${message.notification?.toMap()}");
  print("Contenido de 'data': ${message.data}");

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('last_active_user_id');

  print("UserID encontrado en SharedPreferences: $userId");

  if (userId == null) {
    print(
      "Error: No se encontró un usuario activo. No se guardará la notificación.",
    );
    return;
  }

  // Comprueba si la notificación tiene contenido visible
  if (message.notification != null) {
    final notification = NotificationModel(
      title: message.notification!.title ?? 'Sin Título',
      body: message.notification!.body ?? 'Sin Contenido',
      receivedAt: DateTime.now(),
      type: message.data['type'] ?? 'general',
    );
    await NotificationStorageService.addNotification(userId, notification);
  }
  print("--- BACKGROUND HANDLER FINALIZADO ---");
}

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance =
      NotificationService._privateConstructor();

  UserViewModel? _userViewModel;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationViewModel? _notificationViewModel;

  StreamSubscription? _onMessageSubscription;
  StreamSubscription? _onMessageOpenedAppSubscription;

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('notification_icon');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await _localNotificationsPlugin.initialize(settings);
  }

  Future<void> initNotifications({
    required UserViewModel userViewModel,
    required NotificationViewModel notificationViewModel,
  }) async {
    _userViewModel = userViewModel;
    _notificationViewModel = notificationViewModel;
    await _initLocalNotifications();
    await _requestPermission();

    final fcmToken = await _getToken();
    if (fcmToken != null) {
      await userViewModel.saveFcmToken(fcmToken);
    }
    _setupMessageHandlers();

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage, fromTerminated: true);
    }
  }

  void dispose() {
    _onMessageSubscription?.cancel();
    _onMessageOpenedAppSubscription?.cancel();
  }

  void _handleNotificationTap(
    RemoteMessage message, {
    bool fromTerminated = false,
  }) {
    final userId = _userViewModel?.currentUser?.uid;
    if (userId == null) return;
    if (!fromTerminated) {
      _saveNotification(message, userId);
    }
    final String? profileId = message.data['patientProfileId'];
    if (profileId != null && _userViewModel != null) {
      print('Cambiando al perfil: $profileId');
      _userViewModel!.changeActiveProfileById(profileId);
    }
  }

  void _saveNotification(RemoteMessage message, String userId) {
    if (message.notification != null) {
      final notification = NotificationModel(
        title: message.notification!.title ?? 'Sin Título',
        body: message.notification!.body ?? 'Sin Contenido',
        receivedAt: DateTime.now(),
        type: message.data['type'] ?? 'general',
      );
      NotificationStorageService.addNotification(userId, notification);
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    if (message.notification == null) return;

    final BigTextStyleInformation bigTextStyleInformation =
        BigTextStyleInformation(
          message.notification!.body!,
          htmlFormatBigText: true,
          contentTitle: message.notification!.title,
          htmlFormatContentTitle: true,
        );

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'Notificaciones Importantes',
          channelDescription: 'Este canal es para notificaciones importantes.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          styleInformation: bigTextStyleInformation,
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(presentSound: true),
    );

    final random = Random();
    final int id = random.nextInt(2147483647);

    _localNotificationsPlugin.show(
      id,
      message.notification!.title,
      message.notification!.body,
      notificationDetails,
    );
  }

  void _setupMessageHandlers() {
    dispose();

    _onMessageSubscription = FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) {
      print('Notificación recibida en primer plano!');

      final userId = _userViewModel?.currentUser?.uid;
      if (userId == null) return;

      _saveNotification(message, userId);
      _showLocalNotification(message);

      _notificationViewModel?.loadNotifications(userId);
    });

    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage message) {
          print('Notificación abierta desde segundo plano!');
          _handleNotificationTap(message);
        });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permiso concedido por el usuario');
    } else {
      print('Permiso denegado por el usuario');
    }
  }

  Future<String?> _getToken() async {
    final token = await _firebaseMessaging.getToken();
    print('Token FCM: $token');
    return token;
  }
}
