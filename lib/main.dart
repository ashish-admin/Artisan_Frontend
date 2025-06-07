// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'package:artisan_ai/services/auth_service.dart';
import 'package:artisan_ai/screens/welcome_screen.dart';
import 'package:artisan_ai/screens/login_screen.dart';
import 'package:artisan_ai/theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const ArtisanApp(),
    ),
  );
}

class ArtisanApp extends StatelessWidget {
  const ArtisanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArtisanAI',
      theme: AppTheme.artisanTheme,
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthService>(
        builder: (context, authService, child) {
          return FutureBuilder(
            // This now waits for the AuthService to finish its initial check
            future: authService.onInitializationComplete,
            builder: (context, snapshot) {
              // While waiting, show a loading indicator
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              // After the check is done, decide which screen to show
              if (authService.isAuthenticated) {
                if (kDebugMode) print("Main: Auth state is TRUE, showing WelcomeScreen.");
                return const WelcomeScreen();
              } else {
                if (kDebugMode) print("Main: Auth state is FALSE, showing LoginScreen.");
                return const LoginScreen();
              }
            },
          );
        },
      ),
    );
  }
}