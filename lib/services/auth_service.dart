// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For ChangeNotifier & kDebugMode
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService with ChangeNotifier {
  // THIS IS THE CRITICAL CHANGE - REMOVE THE UNDERSCORE
  static const String baseUrl = "http://127.0.0.1:8000/api/v1"; // Now public
  final _storage = const FlutterSecureStorage();

  String? _token;
  bool _isAuthenticated = false;

  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;

AuthService() {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'auth_token');
    if (kDebugMode) {
      print("AuthService (_tryAutoLogin): Checking for stored token.");
    }
    if (storedToken != null && storedToken.isNotEmpty) { // Check if token is not empty
      _token = storedToken;
      _isAuthenticated = true; // Only set to true if a valid token is found
      if (kDebugMode) {
        print("AuthService (_tryAutoLogin): Token found, user is considered authenticated.");
      }
    } else {
      if (kDebugMode) {
        print("AuthService (_tryAutoLogin): No valid token found or token is empty.");
      }
      _isAuthenticated = false; // Explicitly set to false if no valid token
    }
    notifyListeners(); // Crucial to update consumers
  }

  Future<bool> login(String email, String password) async {
    // Using AuthService.baseUrl explicitly for clarity, though baseUrl directly would also work here.
    final url = Uri.parse('${AuthService.baseUrl}/auth/token');
    if (kDebugMode) {
      print("AuthService (login): Attempting login for '$email' to $url");
    }

    _isAuthenticated = false;
    String? serverErrorDetail;

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'username': email, 'password': password},
      );

      if (kDebugMode) {
        print("AuthService (login): Response status: ${response.statusCode}");
        print("AuthService (login): Response body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _token = responseData['access_token'];
        if (_token != null && _token!.isNotEmpty) {
          await _storage.write(key: 'auth_token', value: _token);
          _isAuthenticated = true;
          if (kDebugMode) {
            print("AuthService (login): Login successful, token stored.");
          }
        } else {
          serverErrorDetail = "Login successful but no access_token in response.";
          if (kDebugMode) {
            print("AuthService (login): $serverErrorDetail");
          }
        }
      } else {
        try {
          final errorData = json.decode(response.body);
          serverErrorDetail = errorData['detail'] ?? "Unknown server error during login.";
          if (kDebugMode) {
            print("AuthService (login): Login failed - Server detail: $serverErrorDetail");
          }
        } catch (e) {
          serverErrorDetail = "Could not parse error detail from server. Non-JSON response likely.";
          if (kDebugMode) {
            print("AuthService (login): Login failed - $serverErrorDetail Status: ${response.statusCode}, Body: ${response.body}");
          }
        }
      }
    } catch (error) {
      serverErrorDetail = "An exception occurred during login attempt. Check network and backend server.";
      if (kDebugMode) {
        print("AuthService (login): Login error (exception caught) - $error");
      }
    }

    notifyListeners();
    return _isAuthenticated;
  }

  Map<String, String> getAuthHeaders() {
    if (_token != null && _token!.isNotEmpty) {
      return {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $_token',
      };
    }
    return {'Content-Type': 'application/json; charset=UTF-8'};
  }

  Future<void> logout() async {
    _token = null;
    _isAuthenticated = false;
    await _storage.delete(key: 'auth_token');
    if (kDebugMode) {
      print("AuthService (logout): Logged out, token deleted.");
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    // Using AuthService.baseUrl explicitly for clarity
    final url = Uri.parse('${AuthService.baseUrl}/auth/register');
    if (kDebugMode) {
      print("AuthService (register): Attempting registration for $email to $url");
    }
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({'email': email, 'password': password, 'is_active': true}),
      );

      if (kDebugMode) {
        print("AuthService (register): Response status: ${response.statusCode}");
        print("AuthService (register): Response body: ${response.body}");
      }

      if (response.statusCode == 201) {
        if (kDebugMode) {
          print("AuthService (register): Registration successful for $email.");
        }
        return {'success': true, 'message': 'Registration successful!'};
      } else {
        try {
          final errorData = json.decode(response.body);
          final detail = errorData['detail'] ?? "Unknown registration error.";
           if (kDebugMode) {
            print("AuthService (register): Registration failed - Server detail: $detail");
          }
          return {'success': false, 'message': detail};
        } catch (e) {
          final errDetail = "Could not parse error detail from server. Non-JSON response likely.";
          if (kDebugMode) {
            print("AuthService (register): Registration failed - $errDetail Status: ${response.statusCode}, Body: ${response.body}");
          }
          return {'success': false, 'message': errDetail};
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print("AuthService (register): Registration error (exception caught) - $error");
      }
      return {'success': false, 'message': 'An exception occurred during registration. Check network/backend.'};
    }
  }
}