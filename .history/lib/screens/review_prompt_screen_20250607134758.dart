// lib/screens/review_prompt_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'package:artisan_ai/services/auth_service.dart';
import 'package:artisan_ai/services/prompt_session_service.dart';
import 'package:artisan_ai/screens/welcome_screen.dart';

class ReviewPromptScreen extends StatefulWidget {
  // CORRECTED: Constructor no longer takes arguments
  const ReviewPromptScreen({super.key});

  @override
  ReviewPromptScreenState createState() => ReviewPromptScreenState();
}

class ReviewPromptScreenState extends State<ReviewPromptScreen> {
  late final TextEditingController _promptController;
  String _llmSuggestion = "Loading recommendation...";
  String _llmSuggestionReason = "";
  bool _isSaving = false;
  bool _isLoading = true;
  String? _loadingError;

  // Store session data locally to avoid repeated Provider calls
  late PromptData _sessionData;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(text: "ArtisanAI is working its magic...");
    
    // Use addPostFrameCallback to ensure context is available for Provider.of
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Read all data from the session service once
      _sessionData = Provider.of<PromptSessionService>(context, listen: false).sessionData;
      _fetchDataFromBackend();
    });
  }

  Future<void> _fetchDataFromBackend() async {
    if (!mounted) return;
    final authService = Provider.of<AuthService>(context, listen: false);

    final requestData = {
      "userGoal": _sessionData.userGoal,
      "selectedOutputFormat": _sessionData.selectedOutputFormat,
      "contextProvided": _sessionData.contextProvided,
      "constraints": _sessionData.constraints,
      "personaDescription": _sessionData.personaDescription,
      "personaSkipped": _sessionData.personaSkipped,
    };
    
    try {
      final responses = await Future.wait([
        authService.refinePromptWithAgent(requestData),
        authService.getLlmSuggestions(requestData),
      ]);

      final promptResponse = responses[0];
      final llmResponse = responses[1];
      String finalError = "";

      if (mounted) {
        if (promptResponse['success'] == true) {
          final craftedPrompt = promptResponse['data']['refined_prompt'];
          _promptController.text = craftedPrompt;
        } else {
          finalError += "Error crafting prompt: ${promptResponse['error']}\n";
          _promptController.text = "Could not generate prompt. Please try again.";
        }

        if (llmResponse['success'] == true) {
          final suggestions = llmResponse['data']['suggestions'] as List;
          if (suggestions.isNotEmpty) {
            _llmSuggestion = suggestions[0]['llm_name'] ?? 'Suggestion not available';
            _llmSuggestionReason = suggestions[0]['reason'] ?? '';
          } else {
            _llmSuggestion = "No specific suggestion found";
            _llmSuggestionReason = llmResponse['data']['notes'] ?? "Try refining your inputs for a better match.";
          }
        } else {
           finalError += "Error getting LLM suggestion: ${llmResponse['error']}";
           _llmSuggestion = "Error";
           _llmSuggestionReason = "Could not retrieve LLM suggestions.";
        }

        setState(() {
          _isLoading = false;
          _loadingError = finalError.isNotEmpty ? finalError.trim() : null;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingError = "A critical error occurred while fetching data: ${e.toString()}";
        });
      }
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _copyPrompt() {
    if (_promptController.text.isEmpty || _isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prompt is not ready or is empty.')));
      return;
    }
    Clipboard.setData(ClipboardData(text: _promptController.text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Intelligent prompt copied to clipboard!')));
  }

  Future<void> _saveConfiguration() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isAuthenticated) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('You must be logged in to save.'), backgroundColor: Theme.of(context).colorScheme.error));
      return;
    }
    if (_isLoading) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please wait for prompt to finish generating.')));
      return;
    }

    String? configName;
    configName = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) { 
        final formKey = GlobalKey<FormState>();
        final nameController = TextEditingController();
        return AlertDialog(
          title: Text('Save Configuration As', style: Theme.of(dialogContext).dialogTheme.titleTextStyle),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Enter a unique name"),
              autofocus: true,
              style: Theme.of(dialogContext).dialogTheme.contentTextStyle,
              validator: (value) {
                if (value == null || value.trim().isEmpty) { return 'Please enter a name.'; }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(dialogContext).pop()),
            TextButton(child: const Text('Save'), onPressed: () {
              if (formKey.currentState!.validate()) { Navigator.of(dialogContext).pop(nameController.text.trim()); }
            }),
          ],
        );
      },
    );

    if (configName == null || configName.isEmpty) return; 

    if(mounted) setState(() { _isSaving = true; });

    final Map<String, dynamic> payload = {
      "name": configName,
      "userGoal": _sessionData.userGoal,
      "selectedOutputFormat": _sessionData.selectedOutputFormat,
      "contextProvided": _sessionData.contextProvided,
      "constraints": _sessionData.constraints,
      "personaDescription": _sessionData.personaDescription,
      "personaSkipped": _sessionData.personaSkipped,
      "constructedPrompt": _promptController.text,
    };

    try {
      final url = Uri.parse('${AuthService.baseUrl}/configurations/'); 
      final response = await http.post(
        url, 
        headers: authService.getAuthHeaders(),
        body: jsonEncode(payload),
      );
      
      if (!mounted) return; 

      if (response.statusCode == 201) { 
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Configuration "$configName" saved successfully!'), backgroundColor: Colors.green));
      } else if (response.statusCode == 409) {
           final errorData = jsonDecode(response.body);
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${errorData['detail'] ?? 'Name might already exist.'}'), backgroundColor: Theme.of(context).colorScheme.error));
      } else { 
          String detail = 'Failed to save. Status: ${response.statusCode}';
          if (response.body.isNotEmpty) {
            try { final errorData = jsonDecode(response.body); detail = errorData['detail'] ?? detail; } catch (_) {}
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $detail'), backgroundColor: Theme.of(context).colorScheme.error));
          if (kDebugMode) { print("Error saving configuration: ${response.statusCode} - ${response.body}"); }
      }
    } catch (e) {
      if (kDebugMode) { print("Exception during save: $e"); }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}'), backgroundColor: Theme.of(context).colorScheme.error),
      );
    } finally {
      if (mounted) {
        setState(() { _isSaving = false; });
      }
    }
  }

  void _startOver() {
    Provider.of<PromptSessionService>(context, listen: false).clearSession();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const WelcomeScreen()), (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // ... (Your build method UI here, as provided previously) ...
  }
}