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
    _selectedTone = constraints['tone'];
    _prioritizeQuality = constraints['prioritizeQuality'] ?? true;
    
    if (!_toneOptions.contains(_selectedTone)) {
      _selectedTone = null;
    }
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
          builder: (context) => const AssignPersonaScreen(), // Navigate without parameters
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (Your build method UI here, using the local controllers and variables) ...
  }
}