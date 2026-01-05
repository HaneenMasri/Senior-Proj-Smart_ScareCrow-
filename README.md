🌾 Smart Scarecrow Mobile Application (Senior Project)
📌 Project Overview

This repository contains the mobile application of the Smart Scarecrow System, developed as a Graduation Project.
The application is built using Flutter and serves as the user interface for monitoring and controlling the smart scarecrow system that protects crops from birds and animals using IoT and computer vision technologies.

The app allows users to manage devices, receive alerts, monitor detected movements, and control system settings remotely.

🎯 Project Objectives

Provide a user-friendly mobile interface for the smart scarecrow system.

Enable real-time monitoring of detected movements.

Allow remote device management.

Send notifications when motion or threats are detected.

Support secure authentication using Firebase.

🛠 Technologies Used

Flutter (Dart)

Firebase Authentication

Firebase Firestore

ESP32 / Raspberry Pi (IoT side – integrated externally)

REST / Firebase-based communication

📁 Project Structure
senior_app/
│
├── android/                  # Android configuration
├── ios/                      # iOS configuration
├── lib/
│   ├── app/
│   │   ├── auth_layout.dart
│   │   └── auth_service.dart
│   │
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── welcome_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── main_screen.dart
│   │   ├── devices_screen.dart
│   │   ├── device_details_screen.dart
│   │   ├── add_device_screen.dart
│   │   ├── detected_movements_screen.dart
│   │   ├── notifications_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── change_password_screen.dart
│   │   ├── update_username_screen.dart
│   │   ├── delete_account_screen.dart
│   │   └── about_app_screen.dart
│   │
│   ├── firebase_options.dart
│   └── main.dart
│
└── pubspec.yaml

📱 Application Screens Description
🔐 Authentication

Splash Screen: Displays app logo while initializing.

Welcome Screen: Entry point for login or registration.

Login Screen: Secure user login using Firebase Authentication.

Register Screen: Create a new account.

🏠 Main Features

Home Screen: Overview of the system status.

Devices Screen: Displays all registered scarecrow devices.

Add Device Screen: Add a new IoT scarecrow device.

Device Details Screen: View detailed information for each device.

Detected Movements Screen: Shows detected movements captured by the system.

Notifications Screen: Alerts and warnings triggered by detected threats.

⚙️ Settings & Account Management

Settings Screen: General application settings.

Change Password Screen

Update Username Screen

Delete Account Screen

About App Screen: Project and application information.

🔐 Security

Firebase Authentication ensures secure login.

User data is protected via Firebase Firestore rules.

Sensitive actions (password change, delete account) require re-authentication.

▶️ How to Run the Project
Prerequisites

Flutter SDK installed

Android Studio or VS Code

Firebase project configured

Steps
flutter pub get
flutter run


⚠️ Make sure firebase_options.dart is correctly configured for your Firebase project.

📌 Notes

This repository includes only the mobile application.

IoT hardware (camera, sensors, Raspberry Pi / ESP32) is handled in a separate system.

The app communicates with the hardware through Firebase / backend services.
