// lib/screens/goal_definition_screen.dart
import 'package:flutter/material.dart';
import 'package:artisan_ai/screens/specify_output_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:artisan_ai/services/prompt_session_service.dart';

class GoalDefinitionScreen extends StatefulWidget {
  const GoalDefinitionScreen({super.key});

  @override
  GoalDefinitionScreenState createState() => GoalDefinitionScreenState();
}

class GoalDefinitionScreenState extends State<GoalDefinitionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _goalController;
  final List<String> _quickGoals = const ["Write", "Summarize", "Code", "Brainstorm", "Translate", "Advise"];
  String? _selectedQuickGoal;

  @override
  void initState() {
    super.initState();
    // Read initial data from the session service
    final sessionService = Provider.of<PromptSessionService>(context, listen: false);
    _goalController = TextEditingController(text: sessionService.sessionData.userGoal);
    // Initialize _selectedQuickGoal if it matches one of our options
    final goalParts = sessionService.sessionData.userGoal.split(':');
    if (goalParts.length > 1 && _quickGoals.contains(goalParts[0])) {
      _selectedQuickGoal = goalParts[0];
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_formKey.currentState!.validate()) {
      final sessionService = Provider.of<PromptSessionService>(context, listen: false);
      String userGoal = _goalController.text.trim();
      
      if (_selectedQuickGoal != null && userGoal.isEmpty) {
         userGoal = _selectedQuickGoal!;
      } else if (_selectedQuickGoal != null && userGoal.isNotEmpty && !userGoal.toLowerCase().contains(_selectedQuickGoal!.toLowerCase())) {
        userGoal = "$_selectedQuickGoal: $userGoal";
      }
      
      // Update the central session state
      sessionService.updateUserGoal(userGoal);

      if (kDebugMode) {
        print("Updated Session Goal: ${sessionService.sessionData.userGoal}");
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SpecifyOutputScreen(), // No longer need to pass data
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (Your build method UI here remains the same) ...
    // It will use the local _goalController which is initialized from the service.
  }
}