// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- Required for Provider.of
import 'package:artisan_ai/services/auth_service.dart'; // <-- Required for AuthService
import 'package:artisan_ai/screens/goal_definition_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _loadConfiguration(BuildContext context) async {
    // This is a placeholder for future implementation.
    // When fully implemented, it will fetch saved configurations for the logged-in user
    // from the backend API and allow the user to select one to pre-fill the co-piloting steps.
    if (context.mounted) { // Check if context is still valid before showing SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Load Configuration - To be fully implemented later!'),
          // Using a color from the theme. Ensure colorScheme.surfaceContainerHighest is defined in your AppTheme.
          // If not, use a more standard color like Theme.of(context).colorScheme.surfaceVariant.
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest ?? Theme.of(context).colorScheme.surfaceVariant,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    // Access AuthService for the logout action.
    // listen: false is appropriate here because this button press triggers an action,
    // and the UI update (navigating to LoginScreen) is handled by the Consumer
    // in main.dart listening to changes in AuthService.isAuthenticated.
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Optional: Placeholder for ArtisanAI Logo
                // const Icon(Icons.palette_outlined, size: 80, color: colorScheme.primary),
                // const SizedBox(height: 20),
                Text(
                  'ArtisanAI',
                  style: textTheme.displayLarge?.copyWith(color: colorScheme.primary), // Using ?. as your analyzer expects it
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your intelligent partner for crafting powerful AI prompts.',
                  style: textTheme.titleMedium?.copyWith( // Using ?. as your analyzer expects it
                      color: colorScheme.onSurface.withAlpha((0.85 * 255).round())),
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
                const SizedBox(height: 40), // Spacer
                // --- TEMPORARY LOGOUT BUTTON (UNCOMMENTED AND ACTIVE) ---
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('TEMP: Logout & Clear Token'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent[700], // Make it visually distinct
                    foregroundColor: Colors.white,
                    minimumSize: const Size(240, 50),
                  ),
                  onPressed: () {
                    authService.logout();
                    // The Consumer in main.dart should automatically rebuild and navigate
                    // to LoginScreen after authService.isAuthenticated becomes false
                    // and notifyListeners() is called from within the logout method.
                    print("WelcomeScreen: TEMP Logout button pressed. Auth state should change.");
                  },
                ),
                // --- END OF TEMPORARY LOGOUT BUTTON ---
              ],
            ),
          ),
        ),
      ),
    );
  }
}