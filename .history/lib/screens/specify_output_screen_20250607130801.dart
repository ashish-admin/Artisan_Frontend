// lib/screens/specify_output_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artisan_ai/services/prompt_session_service.dart';
import 'package:artisan_ai/screens/provide_context_screen.dart';
import 'package:flutter/foundation.dart';

class SpecifyOutputScreen extends StatefulWidget {
  const SpecifyOutputScreen({super.key});

  @override
  State<SpecifyOutputScreen> createState() => SpecifyOutputScreenState();
}

class SpecifyOutputScreenState extends State<SpecifyOutputScreen> {
  final List<String> _outputFormats = const [
    "Paragraph", "Bullet Points", "Numbered List", "JSON", 
    "Code Snippet", "Email", "Short Summary", "Detailed Explanation",
    "Creative Story", "Technical Document", "Marketing Copy"
  ];
  String? _selectedOutputFormat;

  @override
  void initState() {
    super.initState();
    final sessionService = Provider.of<PromptSessionService>(context, listen: false);
    _selectedOutputFormat = sessionService.sessionData.selectedOutputFormat;
    
    if (_selectedOutputFormat != null && !_outputFormats.contains(_selectedOutputFormat)) {
      _selectedOutputFormat = null;
    }
  }

  void _onNextPressed() {
    if (_selectedOutputFormat != null) {
      final sessionService = Provider.of<PromptSessionService>(context, listen: false);
      sessionService.updateOutputFormat(_selectedOutputFormat!);

      if (kDebugMode) {
        print("Updated Session Output Format: ${sessionService.sessionData.selectedOutputFormat}");
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProvideContextScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an output format.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 2: Output Format'),
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
                'What kind of output format are you looking for?',
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose the structure that best fits the AI\'s response.',
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: _outputFormats.map((format) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ChoiceChip(
                      label: Text(format, style: textTheme.bodyLarge),
                      selected: _selectedOutputFormat == format,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedOutputFormat = selected ? format : null;
                        });
                      },
                    ),
                  )).toList(),
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
    );
  }
}