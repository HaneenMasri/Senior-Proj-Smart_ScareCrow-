import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../screens/welcome_screen.dart';
import '../screens/main_screen.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, this.pageIfNotConnected});

  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, authService, child) {
        return StreamBuilder(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            Widget widget;

            if (snapshot.connectionState == ConnectionState.waiting) {
              widget = const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Colors.green),
                ),
              );
            } else if (snapshot.hasData) {
              widget = const MainScreen();
            } else {
              widget = pageIfNotConnected ?? const WelcomeScreen();
            }

            return widget;
          },
        );
      },
    );
  }
}
