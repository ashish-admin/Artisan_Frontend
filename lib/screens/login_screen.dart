// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artisan_ai/services/auth_service.dart';
// Import WelcomeScreen to navigate after login
// import 'package:artisan_ai/screens/welcome_screen.dart'; // We'll handle navigation via main.dart logic

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      bool success = await authService.login(_email, _password);

      if (success) {
        // Navigation will be handled by the Consumer in main.dart listening to auth changes
        print("LoginScreen: Login successful in submit method.");
      } else {
        setState(() {
          _errorMessage = "Login failed. Please check your credentials.";
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = "An error occurred: ${error.toString()}";
      });
    } finally {
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Placeholder for navigating to a registration screen
  void _navigateToRegister() {
    // For now, just print. Later, you'd use Navigator.push to a RegisterScreen.
    print("Navigate to Register Screen - To be implemented");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registration screen - To be implemented!')),
    );
  }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Welcome to ArtisanAI',
                  style: textTheme.displaySmall?.copyWith(color: colorScheme.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please log in to continue',
                  style: textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  style: textTheme.bodyLarge,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value!;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  style: textTheme.bodyLarge,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
                const SizedBox(height: 12),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: colorScheme.error, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Login'),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _navigateToRegister, // Placeholder for registration
                  child: Text(
                    'Don\'t have an account? Register here',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}