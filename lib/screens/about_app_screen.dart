import 'package:flutter/material.dart';
// إذا بدك تضيف رابط خارجي (مثل موقع أو إيميل)، أضف هذا:
// import 'package:url_launcher/url_launcher.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  // دالة لفتح رابط خارجي (اختياري)
  // Future<void> _launchUrl(String url) async {
  //   final Uri uri = Uri.parse(url);
  //   if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
  //     throw Exception('Could not launch $url');
  //   }
  // }

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

            // شعار التطبيق (اختياري - غيّر الصورة حسب مشروعك)
            // CircleAvatar(
            //   radius: 60,
            //   backgroundImage: AssetImage('assets/images/app_logo.png'),
            //   backgroundColor: Colors.transparent,
            // ),
            // أو أيقونة بسيطة إذا ما عندك شعار
            const Icon(
              Icons.app_registration_rounded,
              size: 100,
              color: Color(0xFF2E7D32),
            ),

            const SizedBox(height: 30),

            const Text(
              'My Awesome App', // ← غيّر الاسم لاسم تطبيقك الحقيقي
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Version 1.0.0', // ← عدّل الإصدار حسب تطبيقك
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Welcome to My Awesome App!\n\n'
              'This application is designed to help you manage your tasks efficiently '
              'and stay organized in your daily life.\n\n'
              'We are constantly working to improve the user experience and add new features '
              'based on your feedback.\n\n'
              'Thank you for using our app!',
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

            // بريد إلكتروني للدعم (اضغط عليه يفتح الإيميل)
            GestureDetector(
              onTap: () {
                // _launchUrl('mailto:support@yourapp.com');
                // أو نسخة بسيطة بدون url_launcher:
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening email client...')),
                );
              },
              child: const Text(
                'support@yourapp.com', // ← غيّر الإيميل
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // رابط موقع (اختياري)
            // GestureDetector(
            //   onTap: () => _launchUrl('https://www.yourapp.com'),
            //   child: const Text(
            //     'www.yourapp.com',
            //     style: TextStyle(
            //       fontSize: 16,
            //       color: Colors.blue,
            //       decoration: TextDecoration.underline,
            //     ),
            //   ),
            // ),

            const SizedBox(height: 40),

            const Text(
              '© 2025 Your Company Name. All rights reserved.', // ← غيّر السنة والشركة
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}