import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About This App'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            const Icon(
              Icons.app_registration_rounded,
              size: 100,
              color: Color(0xFF2E7D32),
            ),

            const SizedBox(height: 30),

            const Text(
              'My ScareCrow App',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            const Text(
              'Welcome to Smart Scarecrow App!\n\n'
              'This app helps you monitor your crops and protect them from birds and animals.\n\n'
              'You can control the smart scarecrow, view alerts, and check the status of your fields in real-time.\n\n'
              'Thank you for using the Smart Scarecrow App!',

              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.6),
            ),

            const SizedBox(height: 40),

            const Divider(),

            const SizedBox(height: 20),

            const Text(
              'Need help or have suggestions?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening email client...')),
                );
              },
              child: const Text(
                'support@smartapp.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 40),

            const Text(
              '© 2026 Smart Scarecrow Project. All rights reserved.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
