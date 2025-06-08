// lib/screens/assign_persona_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artisan_ai/services/prompt_session_service.dart';
import 'package:artisan_ai/screens/review_prompt_screen.dart'; 

class AssignPersonaScreen extends StatefulWidget {
  const AssignPersonaScreen({super.key});

  @override
  AssignPersonaScreenState createState() => AssignPersonaScreenState();
}

class AssignPersonaScreenState extends State<AssignPersonaScreen> {
  final _personaController = TextEditingController();
  String? _selectedQuickPersona;
  final List<String> _quickPersonaOptions = const [
    "Expert Analyst", "Creative Storyteller", "Helpful Assistant",
    "Sarcastic Bot", "Objective Reporter", "Enthusiastic Teacher", "Concise Explainer"
  ];

  @override
  void dispose() {
    _personaController.dispose();
    super.dispose();
  }

  void _onNextPressed({bool skipped = false}) {
    String personaDescription;
    if (skipped) {
      personaDescription = "Not specified";
    } else if (_selectedQuickPersona != null && _personaController.text.trim().isEmpty) {
      personaDescription = _selectedQuickPersona!;
    } else if (_personaController.text.trim().isNotEmpty) {
      personaDescription = _personaController.text.trim();
    } else if (_selectedQuickPersona != null) { 
      personaDescription = _selectedQuickPersona!;
    } else { 
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe a persona, select one, or click "Skip Persona".'),
        ),
      );
      return; 
    }
    
    if (mounted) {
      Provider.of<PromptSessionService>(context, listen: false).updatePersona(personaDescription, skipped);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ReviewPromptScreen(),
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
        title: const Text('Step 5: Assign Persona (Optional)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Should the AI adopt a specific persona or role?',
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                "This guides the AI's tone, style, and perspective. e.g., 'Act as an expert historian specializing in ancient Rome,' or 'You are a friendly and encouraging fitness coach.'",
              ),
              const SizedBox(height: 16),
              Text(
                'Quick Personas (Optional):',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 6.0,
                children: _quickPersonaOptions.map((persona) => ChoiceChip(
                  label: Text(persona),
                  selected: _selectedQuickPersona == persona,
                  selectedColor: chipTheme.selectedColor,
                  labelStyle: _selectedQuickPersona == persona 
                              ? chipTheme.secondaryLabelStyle 
                              : chipTheme.labelStyle,
                  backgroundColor: chipTheme.backgroundColor,
                  onSelected: (selected) {
                    setState(() {
                      _selectedQuickPersona = selected ? persona : null;
                      if (selected) {
                        _personaController.clear(); 
                      }
                    });
                  },
                )).toList(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextFormField(
                  controller: _personaController,
                  decoration: const InputDecoration(
                    labelText: 'Describe custom persona here',
                    hintText: 'e.g., "A witty science communicator who uses analogies."',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                  ),
                  style: textTheme.bodyLarge,
                  textAlignVertical: TextAlignVertical.top,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 5,
                  onChanged: (text) {
                    if (text.isNotEmpty && _selectedQuickPersona != null) {
                      setState(() {
                        _selectedQuickPersona = null;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.skip_next_outlined),
                    label: const Text('Skip Persona'),
                    onPressed: () {
                      _onNextPressed(skipped: true);
                    },
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.reviews_outlined),
                    label: const Text('Next: Review Hub'),
                    onPressed: _onNextPressed, 
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}