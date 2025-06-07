// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artisan_ai/services/auth_service.dart';
import 'package:artisan_ai/screens/register_screen.dart';

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
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      // listen: false because we are only calling a method
      final authService = Provider.of<AuthService>(context, listen: false);
      bool success = await authService.login(_email, _password);

      // The Consumer in main.dart handles navigation. We just handle error display here.
      if (!success && mounted) {
        setState(() {
          _errorMessage = "Login failed. Please check your credentials or network connection.";
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() { _errorMessage = "An error occurred: ${error.toString()}"; });
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (Your build method UI here, it should be correct as it's displaying) ...
    // The logic inside _submit is the most important part.
    // For completeness, here is the build method again.
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
                Text('Welcome to ArtisanAI', style: textTheme.displaySmall?.copyWith(color: colorScheme.primary), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Please log in to continue', style: textTheme.titleMedium, textAlign: TextAlign.center),
                const SizedBox(height: 40),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || value.isEmpty || !value.contains('@')) ? 'Please enter a valid email' : null,
                  onSaved: (value) => _email = value!,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) => (value == null || value.isEmpty) ? 'Please enter your password' : null,
                  onSaved: (value) => _password = value!,
                ),
                const SizedBox(height: 12),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(_errorMessage!, style: TextStyle(color: colorScheme.error, fontSize: 14), textAlign: TextAlign.center),
                  ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(onPressed: _submit, child: const Text('Login')),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _navigateToRegister,
                  child: Text('Don\'t have an account? Register here', style: TextStyle(color: colorScheme.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}