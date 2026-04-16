import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../network/dio_client.dart';

/// Top-level background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // FCM handles background/terminated notification display automatically.
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'bringit_high_importance',
    'BringIt Notifications',
    description: 'Order updates and alerts from BringIt',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);

    final initial = await _messaging.getInitialMessage();
    if (initial != null) _onNotificationTap(initial);

    _messaging.onTokenRefresh.listen(_registerToken);
  }

  void _onForegroundMessage(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    _localNotifications.show(
      n.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  void _onNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;
    final orderId = data['orderId'] as String?;
    if (type == 'order' && orderId != null) {
      Get.toNamed('/orders');
    }
  }

  Future<String?> getToken() => _messaging.getToken();

  Future<void> _registerToken(String token) async {
    try {
      await DioClient.getDio()
          .patch('/notifications/fcm-token', data: {'fcmToken': token});
    } catch (_) {}
  }

  Future<void> registerTokenAfterLogin() async {
    final token = await getToken();
    if (token != null) await _registerToken(token);
  }
}
