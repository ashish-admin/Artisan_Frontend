// lib/screens/goal_definition_screen.dart
import 'package:flutter/material.dart';
import 'package:artisan_ai/screens/specify_output_screen.dart';

class GoalDefinitionScreen extends StatefulWidget {
  const GoalDefinitionScreen({super.key});

  @override
  _GoalDefinitionScreenState createState() => _GoalDefinitionScreenState();
}

class _GoalDefinitionScreenState extends State<GoalDefinitionScreen> {
  final _goalController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _quickGoals = ["Write", "Summarize", "Code", "Brainstorm", "Translate", "Advise"];
  String? _selectedQuickGoal;

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_formKey.currentState!.validate()) {
      String userGoal = _goalController.text.trim();
      if (_selectedQuickGoal != null && userGoal.isEmpty) {
         userGoal = _selectedQuickGoal!; // Use chip text if field is empty but chip selected
      } else if (_selectedQuickGoal != null && userGoal.isNotEmpty && !userGoal.toLowerCase().contains(_selectedQuickGoal!.toLowerCase())) {
        // If chip selected and text field has different content, prepend chip text for context
        userGoal = "$_selectedQuickGoal: $userGoal";
      }
      
      print("User Goal Captured: $userGoal");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpecifyOutputScreen(userGoal: userGoal),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final chipTheme = Theme.of(context).chipTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 1: Define Your Goal'),
        leading: Navigator.canPop(context) ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new), // Updated icon
          onPressed: () => Navigator.of(context).pop(),
        ) : null,
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
                  'What\'s the main goal for your AI prompt?',
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text( // UPDATED HELPER TEXT
                  'Be specific! e.g., "Draft a persuasive marketing email for a new fitness app targeting young professionals," or "Explain the concept of black holes to a high school student as if you were Carl Sagan."',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Text(
                  'Quick Start (Optional):',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _quickGoals.map((goal) => ChoiceChip(
                    label: Text(goal),
                    selectedColor: chipTheme.selectedColor,
                    labelStyle: _selectedQuickGoal == goal ? chipTheme.secondaryLabelStyle : chipTheme.labelStyle,
                    backgroundColor: chipTheme.backgroundColor,
                    selected: _selectedQuickGoal == goal,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedQuickGoal = selected ? goal : null;
                        if (selected) {
                           _goalController.text = ""; 
                        }
                      });
                    },
                  )).toList(),
                ),
                const SizedBox(height: 24),
                Expanded( // Allow text field to take more space if needed
                  child: TextFormField(
                    controller: _goalController,
                    decoration: const InputDecoration(
                      labelText: 'Describe your goal in detail',
                      hintText: 'Type your detailed goal here or elaborate on your Quick Start selection...',
                    ),
                    style: textTheme.bodyLarge,
                    validator: (value) {
                      if ((value == null || value.trim().isEmpty) && _selectedQuickGoal == null) {
                        return 'Please define your goal or select a quick start option.';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    minLines: 3,
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