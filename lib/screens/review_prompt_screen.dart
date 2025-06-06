// lib/screens/review_prompt_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

import 'package:artisan_ai/services/auth_service.dart';
import 'package:artisan_ai/screens/welcome_screen.dart';

// PromptConfiguration model (Local to this file for now, or move to a models.dart in Flutter)
class PromptConfiguration {
  final String name;
  final String userGoal;
  final String selectedOutputFormat;
  final String contextProvided;
  final Map<String, dynamic> constraints;
  final String personaDescription;
  final bool personaSkipped;
  final String constructedPrompt;

  PromptConfiguration({
    required this.name,
    required this.userGoal,
    required this.selectedOutputFormat,
    required this.contextProvided,
    required this.constraints,
    required this.personaDescription,
    required this.personaSkipped,
    required this.constructedPrompt,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'userGoal': userGoal,
        'selectedOutputFormat': selectedOutputFormat,
        'contextProvided': contextProvided,
        'constraints': constraints,
        'personaDescription': personaDescription,
        'personaSkipped': personaSkipped,
        'constructedPrompt': constructedPrompt,
      };

  factory PromptConfiguration.fromJson(Map<String, dynamic> json) =>
      PromptConfiguration(
        name: json['name'],
        userGoal: json['userGoal'],
        selectedOutputFormat: json['selectedOutputFormat'],
        contextProvided: json['contextProvided'],
        constraints: Map<String, dynamic>.from(json['constraints']),
        personaDescription: json['personaDescription'],
        personaSkipped: json['personaSkipped'],
        constructedPrompt: json['constructedPrompt'],
      );
}


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
  late TextEditingController _promptController;
  String _llmSuggestion = "Gemini Pro (Default)";
  String _llmSuggestionReason = "";
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    String constructedPrompt = _constructPrompt();
    _promptController = TextEditingController(text: constructedPrompt);
    _updateLlmSuggestion(constructedPrompt);
  }

  String _constructPrompt() {
    StringBuffer promptBuffer = StringBuffer();
    promptBuffer.writeln("## Goal:");
    promptBuffer.writeln(widget.userGoal);
    promptBuffer.writeln("\n## Desired Output Format:");
    promptBuffer.writeln("> ${widget.selectedOutputFormat}");
    if (widget.contextProvided.trim().isNotEmpty) {
      promptBuffer.writeln("\n## Context:");
      promptBuffer.writeln(widget.contextProvided.trim());
    }
    if (!widget.personaSkipped && widget.personaDescription.trim().isNotEmpty && widget.personaDescription.toLowerCase() != "not specified (skipped)" && widget.personaDescription.toLowerCase() != "not specified") {
      promptBuffer.writeln("\n## Persona to Adopt:");
      promptBuffer.writeln("> ${widget.personaDescription.trim()}");
    }
    promptBuffer.writeln("\n## Constraints & Guidelines:");
    bool hasConstraints = false;
    if (widget.constraints["length"] != null && (widget.constraints["length"] as String).trim().isNotEmpty) {
      promptBuffer.writeln("- **Desired Length:** ${widget.constraints["length"]}");
      hasConstraints = true;
    }
    if (widget.constraints["tone"] != null && (widget.constraints["tone"] as String).isNotEmpty) {
      promptBuffer.writeln("- **Tone:** ${widget.constraints["tone"]}");
      hasConstraints = true;
    }
    if (widget.constraints["includeKeywords"] != null && (widget.constraints["includeKeywords"] as String).trim().isNotEmpty) {
      promptBuffer.writeln("- **Keywords to Include:** ${widget.constraints["includeKeywords"]}");
      hasConstraints = true;
    }
    if (widget.constraints["excludeKeywords"] != null && (widget.constraints["excludeKeywords"] as String).trim().isNotEmpty) {
      promptBuffer.writeln("- **Keywords to Exclude:** ${widget.constraints["excludeKeywords"]}");
      hasConstraints = true;
    }
    if (!hasConstraints) {
      promptBuffer.writeln("- No specific textual constraints provided beyond general guidance.");
    }
    promptBuffer.writeln("- **Overall Priority:** ${widget.constraints["prioritizeQuality"] ? "Focus on achieving the highest quality and depth of reasoning." : "Focus on speed and cost-effectiveness where appropriate."}");
    promptBuffer.writeln("\n---\nGenerate the response based on all the above information.");
    return promptBuffer.toString();
  }

  void _updateLlmSuggestion(String promptText) {
    String goalLower = widget.userGoal.toLowerCase();
    String outputFormatLower = widget.selectedOutputFormat.toLowerCase();
    bool prioritizeQuality = widget.constraints["prioritizeQuality"] ?? true;
    String toneLower = (widget.constraints["tone"] as String? ?? "").toLowerCase();
    String contextLower = widget.contextProvided.toLowerCase();
    String suggestion = "Gemini Pro (General Purpose)";
    String reason = "A capable model for diverse tasks.";

    if (goalLower.contains("code") || goalLower.contains("script") || outputFormatLower.contains("code") || outputFormatLower.contains("json") || contextLower.contains("python") || contextLower.contains("javascript")) {
      suggestion = prioritizeQuality ? "Gemini Advanced / GPT-4 Series" : "Gemini Flash / Code Llama";
      reason = prioritizeQuality ? "Excellent for complex coding and logic." : "Good for faster, simpler code generation.";
    } else if (goalLower.contains("story") || goalLower.contains("poem") || toneLower == "creative" || goalLower.contains("write creatively")) {
      suggestion = prioritizeQuality ? "Gemini Pro / Claude 3 Opus" : "Gemini Flash / Claude 3 Sonnet";
      reason = prioritizeQuality ? "Top-tier for rich, nuanced creative writing." : "Great for quick creative drafts and brainstorming.";
    } else if (goalLower.contains("summarize") || outputFormatLower.contains("summary")) {
       suggestion = prioritizeQuality ? "Gemini Pro / Claude 3 Sonnet" : "Gemini Flash";
       reason = prioritizeQuality ? "Provides comprehensive and accurate summaries." : "Offers quick and efficient summarization.";
    } else if (goalLower.contains("analyze") || goalLower.contains("analysis") || goalLower.contains("report") && outputFormatLower.contains("detailed")) {
        suggestion = prioritizeQuality ? "Gemini Advanced / GPT-4 Series" : "Gemini Pro / Claude 3 Sonnet";
        reason = "Strong analytical capabilities for in-depth reports.";
    } else if (prioritizeQuality) {
      suggestion = "Gemini Pro / Claude 3 Sonnet / GPT-4 Series";
      reason = "These models offer high quality for general purpose tasks.";
    } else {
      suggestion = "Gemini Flash / GPT-3.5 Series";
      reason = "Good balance of speed and capability for general tasks.";
    }
    if (mounted) { 
      setState(() {
        _llmSuggestion = suggestion;
        _llmSuggestionReason = reason;
      });
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _copyPrompt() {
    if (_promptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nothing to copy! The prompt is empty.'),
          backgroundColor: Theme.of(context).colorScheme.error, // CORRECT: SnackBar property
        ),
      );
      return;
    }
    Clipboard.setData(ClipboardData(text: _promptController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Prompt copied to clipboard!'),
        backgroundColor: Theme.of(context).colorScheme.secondary, // CORRECT: SnackBar property
                                                                  // (or use theme default by omitting)
      ),
    );
  }

  Future<void> _saveConfiguration() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isAuthenticated || authService.token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You must be logged in to save configurations.'),
            backgroundColor: Theme.of(context).colorScheme.error, // CORRECT: SnackBar property
          ),
        );
      }
      return;
    }

    String? configName;
    configName = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) { 
        TextEditingController nameController = TextEditingController();
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).dialogTheme.backgroundColor ?? Theme.of(dialogContext).cardColor,
          title: Text('Save Configuration As', style: Theme.of(dialogContext).dialogTheme.titleTextStyle),
          content: Form(key: formKey, child: TextFormField(controller: nameController, decoration: InputDecoration(hintText: "Enter a unique name for this configuration"), autofocus: true, style: Theme.of(dialogContext).dialogTheme.contentTextStyle, validator: (value) { if (value == null || value.trim().isEmpty) { return 'Please enter a name.'; } return null; },)),
          actions: <Widget>[ TextButton(child: Text('Cancel', style: TextStyle(color: Theme.of(dialogContext).colorScheme.secondary)), onPressed: () => Navigator.of(dialogContext).pop(),), TextButton(child: Text('Save', style: TextStyle(color: Theme.of(dialogContext).colorScheme.primary)), onPressed: () { if (formKey.currentState!.validate()) { Navigator.of(dialogContext).pop(nameController.text.trim()); } },),],
        );
      },
    );

    if (configName != null && configName.isNotEmpty) {
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

      http.Response? response;
      try {
        final String url = '${AuthService.baseUrl}/configurations/'; 

        response = await http.post(
          Uri.parse(url), 
          headers: authService.getAuthHeaders(),
          body: jsonEncode(payload),
        );
        
        if (!mounted) return; 

        if (response.statusCode == 201) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Configuration "$configName" saved successfully!'),
                backgroundColor: Colors.green, // CORRECT: SnackBar property
              ),
            );
        } else if (response.statusCode == 409) {
             final errorData = jsonDecode(response.body);
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${errorData['detail'] ?? 'Name might already exist.'}'),
                backgroundColor: Theme.of(context).colorScheme.error, // CORRECT: SnackBar property
              ),
            );
        } else {
            String detail = 'Failed to save. Status: ${response.statusCode}';
            if (response.body.isNotEmpty) {
              try { 
                final errorData = jsonDecode(response.body); 
                detail = errorData['detail'] ?? detail; 
              } catch (e) { 
                if (kDebugMode) { print("ReviewPromptScreen: Could not parse JSON error body: ${response.body}"); }
                detail += " (Response: ${response.body.substring(0, (response.body.length > 100) ? 100 : response.body.length )})";
              }
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error saving: $detail'),
                backgroundColor: Theme.of(context).colorScheme.error, // CORRECT: SnackBar property
              ),
            );
            if (kDebugMode) { print("ReviewPromptScreen: Error saving configuration: ${response.statusCode} - ${response.body}"); }
        }
      } catch (e) {
        if (kDebugMode) { print("ReviewPromptScreen: Exception during save: $e"); }
        if (!mounted) return;
        String errorMessage = e.toString();
        if (response != null) { 
          errorMessage += "\nResponse Status: ${response.statusCode}, Body: ${response.body}";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $errorMessage'),
            backgroundColor: Theme.of(context).colorScheme.error, // CORRECT: SnackBar property
          ),
        );
      } finally {
        if (mounted) { setState(() { _isSaving = false; }); }
      }
    }
  }

  void _startOver() {
    Navigator.of(context).pushAndRemoveUntil( MaterialPageRoute(builder: (context) => const WelcomeScreen()), (Route<dynamic> route) => false,);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('ArtisanAI Suggestion Hub'),
        leading: Navigator.canPop(context) ? IconButton(icon: Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.of(context).pop(),) : null,
        actions: [IconButton(icon: Icon(Icons.refresh), tooltip: 'Start Over', onPressed: _startOver,)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Review Your Crafted Prompt:', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),),
              SizedBox(height: 12),
              Expanded(flex: 3, child: TextFormField(controller: _promptController, decoration: InputDecoration(labelText: 'Editable Prompt', alignLabelWithHint: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0),), contentPadding: EdgeInsets.all(12.0)), style: textTheme.bodyLarge?.copyWith(fontFamily: 'monospace'), maxLines: null, keyboardType: TextInputType.multiline, textAlignVertical: TextAlignVertical.top,),),
              SizedBox(height: 16),
              Text('ArtisanAI LLM Suggestion:', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),),
              SizedBox(height: 4),
              Card(child: Padding(padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ Text(_llmSuggestion, style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold),), if(_llmSuggestionReason.isNotEmpty) ...[SizedBox(height: 4), Text(_llmSuggestionReason, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),), ] ],),),),
              SizedBox(height: 16),
              Row(children: [ OutlinedButton.icon(icon: _isSaving ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onSurface))) : Icon(Icons.save_alt), label: Text(_isSaving ? 'Saving...' : 'Save Config'), onPressed: _isSaving ? null : _saveConfiguration,), Spacer(), ElevatedButton.icon(icon: Icon(Icons.copy), label: Text('Copy Prompt'), onPressed: _copyPrompt,), ],),
            ],
          ),
        ),
      ),
    );
  }
}