// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // <-- ADDED THIS IMPORT FOR kDebugMode

import 'package:artisan_ai/services/auth_service.dart';
import 'package:artisan_ai/screens/welcome_screen.dart';
import 'package:artisan_ai/screens/login_screen.dart';
import 'package:artisan_ai/theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const ArtisanApp(), // Added const
    ),
  );
}

class ArtisanApp extends StatelessWidget {
  const ArtisanApp({super.key}); // Added const

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArtisanAI',
      theme: AppTheme.artisanTheme,
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthService>(
        builder: (context, authService, child) {
          if (authService.isAuthenticated) {
            if (kDebugMode) print("Main: User is authenticated, showing WelcomeScreen."); // kDebugMode is now defined
            return const WelcomeScreen();
          } else {
            if (kDebugMode) print("Main: User is NOT authenticated, showing LoginScreen."); // kDebugMode is now defined
            return const LoginScreen();
          }
        },
      ),
      // Define routes if you want named navigation for registration later
      // routes: {
      //   '/login': (ctx) => LoginScreen(),
      //   '/welcome': (ctx) => WelcomeScreen(),
      //   // '/register': (ctx) => RegisterScreen(), // For future
      // },
    );
  }
}