import 'package:flutter/material.dart';
import 'package:senior_app/app/auth_service.dart';
import 'package:senior_app/screens/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onBackToHome;

  const SettingsScreen({super.key, required this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.green),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: onBackToHome,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                ListTile(
                  title: const Text("Delete Account"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/delete-account');
                  },
                ),
                const Divider(),

                ListTile(
                  title: const Text("About Us"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/about-app');
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text("Change Password "),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/change-password');
                  },
                ),
                // const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  title: const Text("Update Username  "),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/update-username');
                  },
                ),

                ListTile(
                  title: const Text("Logout"),
                  leading: const Icon(Icons.logout, color: Colors.red),
                  onTap: () async {
                    try {
                      await authService.value.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("ERROR: $e")));
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
