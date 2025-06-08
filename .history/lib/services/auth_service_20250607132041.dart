// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:async'; // Required for Completer
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService with ChangeNotifier {
  static const String baseUrl = "http://127.0.0.1:8000/api/v1";
  final _storage = const FlutterSecureStorage();

  String? _token;
  bool _isAuthenticated = false;
  final Completer<void> _autoLoginCompleter = Completer<void>();

  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  Future<void> get onInitializationComplete => _autoLoginCompleter.future;

  AuthService() {
    _tryAutoLogin();
  }

  /// Checks for a stored token and verifies it with the backend.
  Future<void> _tryAutoLogin() async {
    try {
      final storedToken = await _storage.read(key: 'auth_token');
      if (kDebugMode) print("AuthService (_tryAutoLogin): Checking for stored token.");
      
      if (storedToken != null && storedToken.isNotEmpty) {
        _token = storedToken;
        bool isTokenValid = await verifyToken();
        if (isTokenValid) {
          _isAuthenticated = true;
          if (kDebugMode) print("AuthService (_tryAutoLogin): Stored token is valid. User is authenticated.");
        } else {
          if (kDebugMode) print("AuthService (_tryAutoLogin): Stored token is EXPIRED or INVALID. Forcing logout.");
          await logout(); // This will set _isAuthenticated to false
        }
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
       if (kDebugMode) print("AuthService (_tryAutoLogin): Error during auto-login: $e");
      _isAuthenticated = false;
    } finally {
      // Mark the initialization as complete so the FutureBuilder in main.dart can proceed.
      if (!_autoLoginCompleter.isCompleted) {
        _autoLoginCompleter.complete();
      }
      notifyListeners();
    }
  }

  /// Verifies the current token by calling a protected endpoint.
  Future<bool> verifyToken() async {
    if (_token == null) return false;
    final url = Uri.parse('${AuthService.baseUrl}/auth/users/me');
    try {
      final response = await http.get(url, headers: getAuthHeaders());
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Attempts to log in by calling the backend /token endpoint.
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('${AuthService.baseUrl}/auth/token');
    _isAuthenticated = false;
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'username': email, 'password': password},
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final newToken = responseData['access_token'];
        if (newToken != null && newToken.isNotEmpty) {
          _token = newToken;
          await _storage.write(key: 'auth_token', value: _token);
          _isAuthenticated = true;
          if (kDebugMode) print("AuthService (login): Login successful, new token stored.");
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      if (kDebugMode) print("AuthService (login): Login exception: $e");
    }
    notifyListeners();
    return false;
  }
  
  /// Returns authentication headers if a token is available.
  Map<String, String> getAuthHeaders() {
    if (_token != null && _token!.isNotEmpty) {
      return {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $_token',
      };
    }
    return {'Content-Type': 'application/json; charset=UTF-8'};
  }

  /// Logs the user out by clearing state and deleting the token.
  Future<void> logout() async {
    _token = null;
    _isAuthenticated = false;
    await _storage.delete(key: 'auth_token');
    if (kDebugMode) {
      print("AuthService (logout): Logged out, token deleted.");
    }
    notifyListeners();
  }

  // --- PRIVATE AUTHENTICATED API HELPERS ---

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      if (kDebugMode) print("AuthService: Received 401 Unauthorized. Logging out automatically.");
      await logout();
      return {'success': false, 'error': 'Session expired. Please log in again.'};
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Handle 204 No Content for DELETE requests
      if (response.statusCode == 204) return {'success': true};
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      try {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'error': errorData['detail'] ?? 'An unknown server error occurred.'};
      } catch (e) {
        return {'success': false, 'error': 'Failed to process server response. Status: ${response.statusCode}'};
      }
    }
  }

  Future<Map<String, dynamic>> _authenticatedPost(Uri url, {Object? body}) async {
    if (!isAuthenticated) return {'success': false, 'error': 'User not authenticated'};
    try {
      final response = await http.post(url, headers: getAuthHeaders(), body: body);
      return await _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'An error occurred: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _authenticatedGet(Uri url) async {
    if (!isAuthenticated) return {'success': false, 'error': 'User not authenticated'};
    try {
      final response = await http.get(url, headers: getAuthHeaders());
      return await _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'An error occurred: ${e.toString()}'};
    }
  }
  
  Future<Map<String, dynamic>> _authenticatedDelete(Uri url) async {
    if (!isAuthenticated) return {'success': false, 'error': 'User not authenticated'};
    try {
      final response = await http.delete(url, headers: getAuthHeaders());
      return await _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': 'An error occurred: ${e.toString()}'};
    }
  }

  // --- PUBLIC API METHODS ---

  Future<Map<String, dynamic>> register(String email, String password) async {
    final url = Uri.parse('${AuthService.baseUrl}/auth/register');
    try {
        final response = await http.post(url, headers: {"Content-Type": "application/json"}, body: json.encode({'email': email, 'password': password, 'is_active': true}));
        if (response.statusCode == 201) { return {'success': true, 'message': 'Registration successful! Please log in.'}; } 
        else {
            final errorData = json.decode(response.body);
            return {'success': false, 'message': errorData['detail'] ?? "Unknown registration error."};
        }
    } catch (e) {
        return {'success': false, 'message': 'An exception occurred. Check network/backend.'};
    }
  }

  Future<Map<String, dynamic>> getLlmSuggestions(Map<String, dynamic> promptData) async {
    final url = Uri.parse('${AuthService.baseUrl}/llm-suggestions/');
    return await _authenticatedPost(url, body: jsonEncode(promptData));
  }

  Future<Map<String, dynamic>> refinePromptWithAgent(Map<String, dynamic> promptData) async {
    final url = Uri.parse('${AuthService.baseUrl}/agent/refine-prompt');
    return await _authenticatedPost(url, body: jsonEncode(promptData));
  }

  Future<Map<String, dynamic>> getConfigurations() async {
    final url = Uri.parse('${AuthService.baseUrl}/configurations/');
    return await _authenticatedGet(url);
  }

  Future<Map<String, dynamic>> deleteConfiguration(int configId) async {
    final url = Uri.parse('${AuthService.baseUrl}/configurations/$configId');
    return await _authenticatedDelete(url);
  }
}