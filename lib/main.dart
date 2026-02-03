// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/splash_screen.dart';
import 'screens/update_username_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/delete_account_screen.dart';
import 'screens/about_app_screen.dart';
import 'screens/register_screen.dart';
import 'app/notification_service.dart';

Future<void> saveTokenToDatabase() async {
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('users_tokens')
          .doc('admin_user')
          .set({'token': token, 'updatedAt': FieldValue.serverTimestamp()});
      print("✅ FCM Token updated in Firestore: $token");
    }
  } catch (e) {
    print("Error saving token: $e");
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await saveTokenToDatabase();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('scarecrow_alerts');
      print('Subscribed to scarecrow_alerts topic successfully!');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  } else {
    print('Topic subscription skipped: Not supported on Web.');
  }

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );

  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScareCrow Application',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const SplashScreen(),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/update-username':
            return MaterialPageRoute(builder: (_) => UpdateUsernameScreen());
          case '/change-password':
            return MaterialPageRoute(builder: (_) => ChangePasswordScreen());
          case '/delete-account':
            return MaterialPageRoute(builder: (_) => DeleteAccountScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => RegisterScreen());
          case '/about-app':
            return MaterialPageRoute(builder: (_) => AboutAppScreen());
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
