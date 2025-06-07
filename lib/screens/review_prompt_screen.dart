// lib/screens/review_prompt_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'package:artisan_ai/services/auth_service.dart';
import 'package:artisan_ai/screens/welcome_screen.dart';

class ReviewPromptScreen extends StatefulWidget {
  final String userGoal;
  final String selectedOutputFormat;
  final String contextProvided;
  final Map<String, dynamic> constraints;
  final String personaDescription;
  final bool personaSkipped;

  const ReviewPromptScreen({
    super.key,
    required this.userGoal,
    required this.selectedOutputFormat,
    required this.contextProvided,
    required this.constraints,
    required this.personaDescription,
    required this.personaSkipped,
  });

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

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(text: "ArtisanAI is crafting your intelligent prompt...");
    _fetchDataFromBackend();
  }

  Future<void> _fetchDataFromBackend() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    final requestData = {
      "userGoal": widget.userGoal,
      "selectedOutputFormat": widget.selectedOutputFormat,
      "contextProvided": widget.contextProvided,
      "constraints": widget.constraints,
      "personaDescription": widget.personaDescription,
      "personaSkipped": widget.personaSkipped,
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
      "userGoal": widget.userGoal,
      "selectedOutputFormat": widget.selectedOutputFormat,
      "contextProvided": widget.contextProvided,
      "constraints": widget.constraints,
      "personaDescription": widget.personaDescription,
      "personaSkipped": widget.personaSkipped,
      "constructedPrompt": _promptController.text,
    };

    try {
      final String url = '${AuthService.baseUrl}/configurations/'; 
      final response = await http.post(
        Uri.parse(url), 
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
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const WelcomeScreen()), (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ArtisanAI Suggestion Hub'),
        leading: Navigator.canPop(context) ? IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.of(context).pop()) : null,
        actions: [IconButton(icon: const Icon(Icons.refresh), tooltip: 'Start Over', onPressed: _startOver)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text('ArtisanAI is working its magic...', style: textTheme.titleMedium),
                ],
              ),
            )
          : _loadingError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: colorScheme.error, size: 48),
                    const SizedBox(height: 16),
                    Text("Error Fetching Data", style: textTheme.headlineSmall?.copyWith(color: colorScheme.error)),
                    const SizedBox(height: 8),
                    Text(_loadingError!, style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          : Column( 
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Review Your Crafted Prompt:', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Expanded(flex: 3, child: TextFormField(controller: _promptController, decoration: const InputDecoration(labelText: 'Editable Prompt', alignLabelWithHint: true, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))), contentPadding: EdgeInsets.all(12.0)), style: textTheme.bodyLarge?.copyWith(fontFamily: 'monospace'), maxLines: null, keyboardType: TextInputType.multiline, textAlignVertical: TextAlignVertical.top)),
                const SizedBox(height: 16),
                Text('ArtisanAI LLM Suggestion:', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Card(child: Padding(padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ Text(_llmSuggestion, style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold)), if(_llmSuggestionReason.isNotEmpty) ...[const SizedBox(height: 4), Text(_llmSuggestionReason, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant))] ],),),),
                const SizedBox(height: 16),
                Row(children: [ OutlinedButton.icon(icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_alt), label: Text(_isSaving ? 'Saving...' : 'Save Config'), onPressed: _isSaving ? null : _saveConfiguration), const Spacer(), ElevatedButton.icon(icon: const Icon(Icons.copy), label: const Text('Copy Prompt'), onPressed: _copyPrompt) ],),
              ],
            ),
        ),
      ),
    );
  }
}