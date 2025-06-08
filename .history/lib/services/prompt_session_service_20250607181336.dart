// lib/services/prompt_session_service.dart
import 'package:flutter/material.dart';
import 'dart:convert';

class PromptSessionService with ChangeNotifier {
  // Data for the current prompt session
  String userGoal = '';
  String selectedOutputFormat = '';
  String contextProvided = '';
  Map<String, dynamic> constraints = {};
  String personaDescription = '';
  bool personaSkipped = false;
  String constructedPrompt = '';
  
  // To track which saved config is being edited, if any
  int? configurationId;

  // Method to update the service with data from a loaded configuration
  void loadFromMap(Map<String, dynamic> config) {
    userGoal = config['userGoal'] ?? '';
    selectedOutputFormat = config['selectedOutputFormat'] ?? '';
    contextProvided = config['contextProvided'] ?? '';

    // The backend saves constraints as a JSON string. We need to decode it.
    if (config['constraints_json'] != null && config['constraints_json'] is String) {
        try {
            constraints = Map<String, dynamic>.from(jsonDecode(config['constraints_json']));
        } catch (e) {
            constraints = {}; // Reset if decoding fails
        }
    } else if (config['constraints'] is Map) {
        constraints = Map<String, dynamic>.from(config['constraints']);
    } else {
        constraints = {};
    }
    
    personaDescription = config['personaDescription'] ?? '';
    personaSkipped = config['personaSkipped'] ?? false;
    constructedPrompt = config['constructedPrompt'] ?? '';
    configurationId = config['id'];
    
    notifyListeners();
  }

  // Update methods for each step of the flow
  void updateGoal(String goal) {
    userGoal = goal;
    notifyListeners();
  }

  void updateOutputFormat(String format) {
    selectedOutputFormat = format;
    notifyListeners();
  }

  void updateContext(String context) {
    contextProvided = context;
    notifyListeners();
  }

  void updateConstraints(Map<String, dynamic> newConstraints) {
    constraints = newConstraints;
    notifyListeners();
  }

  void updatePersona(String description, bool skipped) {
    personaDescription = description;
    personaSkipped = skipped;
    notifyListeners();
  }
  
  void updateConstructedPrompt(String prompt) {
      constructedPrompt = prompt;
      notifyListeners();
  }

  // Resets the service to its initial state for a new prompt.
  void clear() {
    userGoal = '';
    selectedOutputFormat = '';
    contextProvided = '';
    constraints = {};
    personaDescription = '';
    personaSkipped = false;
    constructedPrompt = '';
    configurationId = null;
    notifyListeners();
  }

  // Helper to package data for API requests
  Map<String, dynamic> toApiRequestData() {
    return {
      "userGoal": userGoal,
      "selectedOutputFormat": selectedOutputFormat,
      "contextProvided": contextProvided,
      "constraints": constraints,
      "personaDescription": personaDescription,
      "personaSkipped": personaSkipped,
    };
  }
}