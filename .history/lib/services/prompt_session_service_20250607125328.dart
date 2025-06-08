// lib/services/prompt_session_service.dart
import 'package:flutter/foundation.dart';

// Helper class to hold the data for a single co-piloting session.
class PromptData {
  String userGoal;
  String selectedOutputFormat;
  String contextProvided;
  Map<String, dynamic> constraints;
  String personaDescription;
  bool personaSkipped;

  PromptData({
    this.userGoal = '',
    this.selectedOutputFormat = '',
    this.contextProvided = '',
    Map<String, dynamic>? constraints,
    this.personaDescription = '',
    this.personaSkipped = false,
  }) : constraints = constraints ?? {'prioritizeQuality': true}; // Ensure constraints is never null
}

class PromptSessionService with ChangeNotifier {
  PromptData _sessionData = PromptData();

  PromptData get sessionData => _sessionData;

  // Method to update the entire session, e.g., when loading a saved config
  void loadSession(Map<String, dynamic> savedConfig) {
    _sessionData = PromptData(
      userGoal: savedConfig['userGoal'] ?? '',
      selectedOutputFormat: savedConfig['selectedOutputFormat'] ?? '',
      contextProvided: savedConfig['contextProvided'] ?? '',
      constraints: Map<String, dynamic>.from(savedConfig['constraints'] ?? {'prioritizeQuality': true}),
      personaDescription: savedConfig['personaDescription'] ?? '',
      personaSkipped: savedConfig['personaSkipped'] ?? false,
    );
    if (kDebugMode) {
      print("PromptSessionService: Session loaded with name '${savedConfig['name']}'.");
    }
    notifyListeners(); // Notify listeners that data has changed
  }

  // Method to clear the session, e.g., when starting a new prompt
  void clearSession() {
    _sessionData = PromptData();
    if (kDebugMode) {
      print("PromptSessionService: Session cleared.");
    }
    notifyListeners();
  }

  // Individual update methods for each step of the co-pilot
  void updateUserGoal(String goal) {
    _sessionData.userGoal = goal;
    notifyListeners();
  }

  void updateOutputFormat(String format) {
    _sessionData.selectedOutputFormat = format;
    notifyListeners();
  }

  void updateContext(String context) {
    _sessionData.contextProvided = context;
    notifyListeners();
  }
  
  void updateConstraints(Map<String, dynamic> newConstraints) {
    _sessionData.constraints = newConstraints;
    notifyListeners();
  }

  void updatePersona(String description, bool skipped) {
    _sessionData.personaDescription = description;
    _sessionData.personaSkipped = skipped;
    notifyListeners();
  }
}