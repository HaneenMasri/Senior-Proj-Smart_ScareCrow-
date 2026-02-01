// lib/app/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'scarecrow_channel';

  static Future<void> init() async {
    // 1️⃣ طلب الإذن (لوجيك فقط)
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // 2️⃣ إنشاء Notification Channel (إجباري)
    if (!kIsWeb) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        'Scarecrow Alerts',
        description: 'Notifications for bird detection events',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }

    // 3️⃣ تهيئة local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings),
    );

    // 4️⃣ الحصول على Token
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');

    // 5️⃣ الاشتراك في Topic (Mobile فقط)
    if (!kIsWeb) {
      await _messaging.subscribeToTopic('scarecrow_alerts');
    }

    // 6️⃣ Foreground listener
    FirebaseMessaging.onMessage.listen(_showNotification);
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          'Scarecrow Alerts',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Scarecrow Alert',
      message.notification?.body ?? 'Bird detected',
      details,
    );
  }
}
