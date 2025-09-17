// lib/data/network/notification_service.dart
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:p_hn25/data/models/notification_model.dart';
import 'package:p_hn25/data/network/notification_storage_service.dart';
import 'package:p_hn25/firebase_options.dart';
import 'package:p_hn25/view_model/user_view_model.dart';

// CAMBIO: Esta función ahora SIEMPRE guarda la notificación que llega.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Es necesario inicializar Firebase aquí para que los servicios funcionen en segundo plano.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print(
    "Notificación recibida en segundo plano/terminado: ${message.messageId}",
  );

  if (message.notification != null) {
    final notification = NotificationModel(
      title: message.notification!.title ?? 'Sin Título',
      body: message.notification!.body ?? 'Sin Contenido',
      receivedAt: DateTime.now(),
    );
    // Guardamos la notificación para poder verla después, aunque el usuario no la toque.
    await NotificationStorageService.addNotification(notification);
  }
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('notification_icon');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await _localNotificationsPlugin.initialize(settings);
  }

  Future<void> initNotifications(UserViewModel userViewModel) async {
    await _initLocalNotifications();
    await _requestPermission();

    final fcmToken = await _getToken();
    if (fcmToken != null) {
      await userViewModel.saveFcmToken(fcmToken);
    }
    _setupMessageHandlers();

    // Se revisa si la app se abrió desde una notificación (estando cerrada)
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      // El _handler ya guardó la notificación. Aquí solo manejaríamos la navegación.
      print('La app se abrió desde una notificación (estaba cerrada).');
    }
  }

  void _saveNotification(RemoteMessage message) {
    if (message.notification != null) {
      print(
        "Guardando notificación desde primer plano: ${message.notification!.title}",
      );
      final notification = NotificationModel(
        title: message.notification!.title ?? 'Sin Título',
        body: message.notification!.body ?? 'Sin Contenido',
        receivedAt: DateTime.now(),
      );
      NotificationStorageService.addNotification(notification);
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
      iOS: DarwinNotificationDetails(presentSound: true),
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
    // App ABIERTA: Se muestra localmente y se guarda.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificación recibida en primer plano!');
      _saveNotification(message);
      _showLocalNotification(message);
    });

    // App EN SEGUNDO PLANO Y SE TOCA LA NOTIFICACIÓN:
    // El _handler ya la guardó, así que aquí solo manejamos la navegación.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notificación abierta desde segundo plano!');
      // No es necesario llamar a _saveNotification aquí, pero no hace daño.
    });

    // App EN SEGUNDO PLANO O CERRADA (llega la notificación):
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
