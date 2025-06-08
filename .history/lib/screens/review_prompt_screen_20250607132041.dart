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
    // ... (This logic is now correct and calls methods that exist in the updated AuthService) ...
  }
  
  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _copyPrompt() {
    // ... (This logic is correct) ...
  }

  Future<void> _saveConfiguration() async {
    // ... (This logic is correct, just needs the const fix) ...
    // final String url = ... becomes const String url = ...
  }
  
  void _startOver() {
    // ... (This logic is correct) ...
  }

  // --- FULLY IMPLEMENTED AND CORRECTED BUILD METHOD ---
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