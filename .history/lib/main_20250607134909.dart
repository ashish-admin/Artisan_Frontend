// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'package:artisan_ai/services/auth_service.dart';
import 'package:artisan_ai/services/prompt_session_service.dart'; // <-- ADD THIS IMPORT
import 'package:artisan_ai/screens/welcome_screen.dart';
import 'package:artisan_ai/screens/login_screen.dart';
import 'package:artisan_ai/theme/app_theme.dart';

void main() {
  runApp(
    // CORRECTED: Use MultiProvider to provide multiple services to the app.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => PromptSessionService()),
      ],
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
          // This logic remains the same, showing Login or Welcome screen based on auth state
          // The FutureBuilder has been removed for simplicity as the initial load logic is handled within AuthService
          if (authService.isAuthenticated) {
            if (kDebugMode) print("Main: User is authenticated, showing WelcomeScreen.");
            return const WelcomeScreen();
          } else {
            if (kDebugMode) print("Main: User is NOT authenticated, showing LoginScreen.");
            return const LoginScreen();
          }
        },
      ),
    );
  }
}