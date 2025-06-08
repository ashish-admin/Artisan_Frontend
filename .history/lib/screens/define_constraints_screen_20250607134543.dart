// lib/screens/define_constraints_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artisan_ai/services/prompt_session_service.dart';
import 'package:artisan_ai/screens/assign_persona_screen.dart';
import 'package:flutter/foundation.dart';

class DefineConstraintsScreen extends StatefulWidget {
  const DefineConstraintsScreen({super.key});

  @override
  DefineConstraintsScreenState createState() => DefineConstraintsScreenState();
}

class DefineConstraintsScreenState extends State<DefineConstraintsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _lengthController;
  late final TextEditingController _includeKeywordsController;
  late final TextEditingController _excludeKeywordsController;

  String? _selectedTone;
  final List<String> _toneOptions = const ["Formal", "Casual", "Persuasive", "Neutral", "Creative", "Technical", "Humorous"];
  
  bool _prioritizeQuality = true;

  @override
  void initState() {
    super.initState();
    final sessionService = Provider.of<PromptSessionService>(context, listen: false);
    final constraints = sessionService.sessionData.constraints;

    _lengthController = TextEditingController(text: constraints['length'] ?? '');
    _includeKeywordsController = TextEditingController(text: constraints['includeKeywords'] ?? '');
    _excludeKeywordsController = TextEditingController(text: constraints['excludeKeywords'] ?? '');
    
    final initialTone = constraints['tone'] as String?;
    if (initialTone != null && _toneOptions.contains(initialTone)) {
      _selectedTone = initialTone;
    }
    
    _prioritizeQuality = constraints['prioritizeQuality'] ?? true;
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _includeKeywordsController.dispose();
    _excludeKeywordsController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_formKey.currentState!.validate()) {
      final sessionService = Provider.of<PromptSessionService>(context, listen: false);

      final Map<String, dynamic> newConstraints = {
        "length": _lengthController.text.trim(),
        "tone": _selectedTone ?? "", 
        "includeKeywords": _includeKeywordsController.text.trim(),
        "excludeKeywords": _excludeKeywordsController.text.trim(),
        "prioritizeQuality": _prioritizeQuality,
      };
      
      sessionService.updateConstraints(newConstraints);

      if (kDebugMode) {
        print("Updated Session Constraints: ${sessionService.sessionData.constraints}");
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AssignPersonaScreen(), // Correctly navigates without arguments
        ),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {String? hint, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, hintText: hint),
        maxLines: maxLines,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final chipTheme = Theme.of(context).chipTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 4: Constraints & Priorities'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Specify constraints and set task priorities:',
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 8),
                    children: [
                      _buildTextField(_lengthController, "Desired Length (approx.)", hint: "e.g., 1 short paragraph, ~500 words", maxLines: 2),
                      const SizedBox(height: 16),
                      Text("Tone:", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 6.0,
                        children: _toneOptions.map((tone) => ChoiceChip(
                          label: Text(tone),
                          selected: _selectedTone == tone,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTone = selected ? tone : null;
                            });
                          },
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(_includeKeywordsController, "Keywords/Phrases to Include", hint: "Comma-separated", maxLines:2),
                      _buildTextField(_excludeKeywordsController, "Keywords/Phrases to Exclude", hint: "Comma-separated", maxLines:2),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text("Prioritize Quality & Deep Reasoning?", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                          Switch(
                            value: _prioritizeQuality,
                            onChanged: (value) {
                              setState(() {
                                _prioritizeQuality = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                       Padding(
                         padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                         child: Text(
                          _prioritizeQuality 
                              ? "Focus will be on the most thorough, accurate, and well-reasoned response."
                              : "Focus will be on faster, potentially more concise or cost-effective responses.",
                          style: textTheme.bodySmall,
                      ),
                       ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _onNextPressed,
                  child: const Text('Next Step'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}