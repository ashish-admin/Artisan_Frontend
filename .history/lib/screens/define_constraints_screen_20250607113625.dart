// lib/screens/define_constraints_screen.dart
import 'package:flutter/material.dart';
import 'package:artisan_ai/screens/assign_persona_screen.dart';

class DefineConstraintsScreen extends StatefulWidget {
  final String userGoal;
  final String selectedOutputFormat;
  final String contextProvided;

  const DefineConstraintsScreen({
    super.key,
    required this.userGoal,
    required this.selectedOutputFormat,
    required this.contextProvided,
  });

  @override
  _DefineConstraintsScreenState createState() => _DefineConstraintsScreenState();
}

class _DefineConstraintsScreenState extends State<DefineConstraintsScreen> {
  final _formKey = GlobalKey<FormState>(); // Defined with one underscore

  final _lengthController = TextEditingController();
  final _includeKeywordsController = TextEditingController();
  final _excludeKeywordsController = TextEditingController();

  String? _selectedTone;
  final List<String> _toneOptions = ["Formal", "Casual", "Persuasive", "Neutral", "Creative", "Technical", "Humorous"];
  
  bool _prioritizeQuality = true; 

  @override
  void dispose() {
    _lengthController.dispose();
    _includeKeywordsController.dispose();
    _excludeKeywordsController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); 

      final Map<String, dynamic> constraints = {
        "length": _lengthController.text.trim(),
        "tone": _selectedTone ?? "", 
        "includeKeywords": _includeKeywordsController.text.trim(),
        "excludeKeywords": _excludeKeywordsController.text.trim(),
        "prioritizeQuality": _prioritizeQuality,
      };

      print("User Goal: ${widget.userGoal}");
      print("Selected Output Format: ${widget.selectedOutputFormat}");
      print("Context Provided: ${widget.contextProvided}");
      print("Constraints: $constraints");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AssignPersonaScreen(
            userGoal: widget.userGoal,
            selectedOutputFormat: widget.selectedOutputFormat,
            contextProvided: widget.contextProvided,
            constraints: constraints,
          ),
        ),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {String? hint, bool isOptional = true, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint ?? 'Enter ${label.toLowerCase()}',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        maxLines: maxLines,
        validator: (value) {
          if (!isOptional && (value == null || value.trim().isEmpty)) {
            // return 'Please enter $label'; 
          }
          return null;
        },
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
            key: _formKey, // CORRECTED: Uses _formKey with one underscore
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
                      _buildTextField(_lengthController, "Desired Length (approx.)", hint: "e.g., 1 short paragraph, ~500 words, concise as possible", isOptional: true, maxLines: 2),
                      const SizedBox(height: 16),
                      Text("Tone:", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 6.0,
                        children: _toneOptions.map((tone) => ChoiceChip(
                          label: Text(tone),
                          selected: _selectedTone == tone,
                          selectedColor: chipTheme.selectedColor,
                           labelStyle: _selectedTone == tone 
                                  ? chipTheme.secondaryLabelStyle 
                                  : chipTheme.labelStyle,
                          backgroundColor: chipTheme.backgroundColor,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTone = selected ? tone : null;
                            });
                          },
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(_includeKeywordsController, "Keywords/Phrases to Include", hint: "Comma-separated", isOptional: true, maxLines:2),
                      _buildTextField(_excludeKeywordsController, "Keywords/Phrases to Exclude", hint: "Comma-separated", isOptional: true, maxLines:2),
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
                              ? "Focus will be on the most thorough, accurate, and well-reasoned response, potentially taking more time or resources."
                              : "Focus will be on faster, potentially more concise or cost-effective responses, which might be less nuanced.",
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