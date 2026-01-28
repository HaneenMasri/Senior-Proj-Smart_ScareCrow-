import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    // 1. طلب الإذن
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _messaging.getToken(
        vapidKey:
            "BCjvftPez8Vc7Cd87SiN7cpmL0X1E-sCIB9lpEHgBqOoiNB_xu9ua5bjKae-bDQDmg1r3D_eyPRHrfDU-TpgLIY",
      );

      debugPrint('FCM Token: $token');
    }

    // 3. استقبال الإشعار والتطبيق مفتوح
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 Notification Received');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');

      // ملاحظة: على الويب والتطبيق مفتوح، المتصفح لا يظهر Banner تلقائياً
      // يمكنك هنا إظهار SnackBar أو Alert ليعرف المستخدم بوجود إشعار
    });
  }
}
