// lib/screens/provide_context_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artisan_ai/services/prompt_session_service.dart';
import 'package:artisan_ai/screens/define_constraints_screen.dart';
import 'package:flutter/foundation.dart';

class ProvideContextScreen extends StatefulWidget {
  const ProvideContextScreen({super.key});

  @override
  State<ProvideContextScreen> createState() => ProvideContextScreenState();
}

class ProvideContextScreenState extends State<ProvideContextScreen> {
  late final TextEditingController _contextController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final sessionService = Provider.of<PromptSessionService>(context, listen: false);
    _contextController = TextEditingController(text: sessionService.sessionData.contextProvided);
  }

  @override
  void dispose() {
    _contextController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_formKey.currentState!.validate()) {
      final sessionService = Provider.of<PromptSessionService>(context, listen: false);
      sessionService.updateContext(_contextController.text.trim());

      if (kDebugMode) {
        print("Updated Session Context: ${sessionService.sessionData.contextProvided}");
      }

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
                  'What essential background or context should the AI know?',
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                const Text(
                  'e.g., Target audience, specific documents to reference, key definitions, desired style influences, or even examples of what NOT to do.',
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: TextFormField(
                    controller: _contextController,
                    decoration: const InputDecoration(
                      labelText: 'Enter context here',
                      hintText: 'Provide as much relevant detail as possible...',
                      alignLabelWithHint: true,
                    ),
                    textAlignVertical: TextAlignVertical.top,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    maxLines: null, 
                    minLines: 8,
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