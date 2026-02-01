// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, i) => ListTile(
          leading: const Icon(Icons.notification_important),
          title: Text("New movement detected #${i + 1}"),
          subtitle: const Text("Tap to view"),
        ),
      ),
    );
  }
}
