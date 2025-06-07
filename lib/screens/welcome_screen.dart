// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artisan_ai/services/auth_service.dart';
import 'package:artisan_ai/screens/goal_definition_screen.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _loadConfiguration(BuildContext context) async {
    // Placeholder for future implementation
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Load Configuration - To be fully implemented later!'),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ArtisanAI Home'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              authService.logout();
              if (kDebugMode) {
                print("WelcomeScreen: Logout button pressed from AppBar.");
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Welcome!',
                  style: textTheme.displayLarge?.copyWith(color: colorScheme.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Start a new session or load a saved configuration.',
                  style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.85)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Start New Prompt'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GoalDefinitionScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(240, 50)),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Load Configuration'),
                  onPressed: () => _loadConfiguration(context),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(240, 50)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}