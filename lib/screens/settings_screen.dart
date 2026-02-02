// screens/settings_screen.dart
import 'package:flutter/material.dart';

import 'package:senior_app/app/auth_service.dart';
import 'package:senior_app/screens/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          "Settings",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 24),
        ListTile(
          title: const Text("Account Info"),
          trailing: const Icon(Icons.chevron_right),
        ),
        ListTile(
          title: const Text("Language"),
          trailing: const Icon(Icons.chevron_right),
        ),
        ListTile(
          title: const Text("About Us"),
          trailing: const Icon(Icons.chevron_right),
        ),
        ListTile(
          title: const Text("Logout"),
          leading: const Icon(Icons.logout, color: Colors.red),
          onTap: () async {
            try {
              await authService.value.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("ERROR  : $e")));
            }
          },
        ),
      ],
    );
  }
}
