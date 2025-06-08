// lib/screens/specify_output_screen.dart
import 'package:flutter/material.dart';
import 'package:artisan_ai/screens/provide_context_screen.dart';

class SpecifyOutputScreen extends StatefulWidget {
  final String userGoal;

  const SpecifyOutputScreen({super.key, required this.userGoal});

  @override
  _SpecifyOutputScreenState createState() => _SpecifyOutputScreenState();
}

class _SpecifyOutputScreenState extends State<SpecifyOutputScreen> {
  final List<String> _outputFormats = [
    "Paragraph", "Bullet Points", "Numbered List", "JSON", 
    "Code Snippet", "Email", "Short Summary", "Detailed Explanation",
    "Creative Story", "Technical Document", "Marketing Copy" // Added more options
  ];
  String? _selectedOutputFormat;

  void _onNextPressed() {
    if (_selectedOutputFormat != null) {
      print("User Goal: ${widget.userGoal}");
      print("Selected Output Format: $_selectedOutputFormat");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProvideContextScreen(
            userGoal: widget.userGoal,
            selectedOutputFormat: _selectedOutputFormat!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an output format.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
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
              Text(
                'Choose the structure that best fits the AI\'s response. This helps the AI understand the desired presentation.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: _outputFormats.map((format) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0), // Increased vertical padding
                    child: ChoiceChip(
                      label: Text(format, style: textTheme.bodyLarge),
                      selectedColor: chipTheme.selectedColor,
                      labelStyle: _selectedOutputFormat == format 
                                  ? chipTheme.secondaryLabelStyle?.copyWith(fontSize: textTheme.bodyLarge?.fontSize) 
                                  : chipTheme.labelStyle?.copyWith(fontSize: textTheme.bodyLarge?.fontSize),
                      backgroundColor: chipTheme.backgroundColor,
                      selected: _selectedOutputFormat == format,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedOutputFormat = selected ? format : null;
                        });
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      elevation: _selectedOutputFormat == format ? 2 : 0, // Add elevation when selected
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