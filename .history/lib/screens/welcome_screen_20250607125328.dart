// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artisan_ai/services/auth_service.dart';
import 'package:artisan_ai/services/prompt_session_service.dart'; // <-- ADD THIS IMPORT
import 'package:artisan_ai/screens/goal_definition_screen.dart';
import 'package:artisan_ai/screens/saved_configurations_screen.dart';
import 'package:flutter/foundation.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final authService = Provider.of<AuthService>(context, listen: false);
    // Get the session service
    final sessionService = Provider.of<PromptSessionService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ArtisanAI Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              authService.logout();
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
              children: <Widget>[
                Text('Welcome!', style: textTheme.displayLarge?.copyWith(color: colorScheme.primary), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text(
                  'Start a new session or load a saved configuration.',
                  style: textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Start New Prompt'),
                  onPressed: () {
                    // CORRECTED: Clear the session before starting a new prompt
                    sessionService.clearSession();
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SavedConfigurationsScreen()),
                    );
                  },
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