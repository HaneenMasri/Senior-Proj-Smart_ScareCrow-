import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // أضفنا الفيربيس هنا
import 'welcome_screen.dart';
import 'main_screen.dart'; // تأكدي من استيراد الشاشة الرئيسية لتطبيقك

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // هنا المنطق الجديد للفحص
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        // فحص حالة المستخدم الحالية
        User? user = FirebaseAuth.instance.currentUser;

        Widget nextScreen;

        if (user != null) {
          // إذا كان مسجل دخول -> ارسله للشاشة الرئيسية مباشرة (مثل فيسبوك)
          nextScreen = const MainScreen();
        } else {
          // إذا لم يسجل دخول -> ارسله لصفحة الترحيب/اللوج إن
          nextScreen = const WelcomeScreen();
        }

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) =>
                nextScreen, // نستخدم الشاشة التي حددها الفحص
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // كود التصميم الخاص بك كما هو بدون تغيير
    final primaryColor = Colors.orange.shade400;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.orange.shade50],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Image.network(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTfviibigpDln6V_g4BBX8PtYMrrfwyXkMFdQ&s',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'SCARECROW AI',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                  letterSpacing: 4,
                ),
              ),
              const Text(
                'INTELLIGENT FARM PROTECTION',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: Text(
                  'POWERED BY SMART IOT',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
