// lib/screens/provide_context_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artisan_ai/services/prompt_session_service.dart';
import 'package:artisan_ai/screens/define_constraints_screen.dart';

class ProvideContextScreen extends StatefulWidget {
  const ProvideContextScreen({super.key});

  @override
  _ProvideContextScreenState createState() => _ProvideContextScreenState();
}

class _ProvideContextScreenState extends State<ProvideContextScreen> {
  final _contextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _contextController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_formKey.currentState!.validate()) {
      final String contextProvided = _contextController.text.trim();
      Provider.of<PromptSessionService>(context, listen: false).updateContext(contextProvided);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DefineConstraintsScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 3: Provide Context'),
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
                  'What essential background or context should the AI know for this task?',
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'e.g., Target audience, specific documents/data to reference, key definitions, desired style influences, or even examples of what NOT to do.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: TextFormField(
                    controller: _contextController,
                    decoration: InputDecoration(
                      labelText: 'Enter context here',
                      hintText: 'Provide as much relevant detail as possible...',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    style: textTheme.bodyLarge,
                    textAlignVertical: TextAlignVertical.top,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    maxLines: null, 
                    minLines: 8,  
                    validator: (value) {
                      if (value != null && value.length > 5000) {
                        return 'Context might be too long (max 5000 characters for optimal processing).';
                      }
                      return null; 
                    },
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