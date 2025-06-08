// lib/screens/saved_configurations_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artisan_ai/services/auth_service.dart';
import 'package:artisan_ai/services/prompt_session_service.dart';
import 'package:artisan_ai/screens/review_prompt_screen.dart';

class SavedConfigurationsScreen extends StatefulWidget {
  const SavedConfigurationsScreen({super.key});

  @override
  SavedConfigurationsScreenState createState() => SavedConfigurationsScreenState();
}

class SavedConfigurationsScreenState extends State<SavedConfigurationsScreen> {
  late Future<List<dynamic>> _configsFuture;

  @override
  void initState() {
    super.initState();
    _configsFuture = _fetchConfigs();
  }

  Future<List<dynamic>> _fetchConfigs() {
    final authService = Provider.of<AuthService>(context, listen: false);
    // Assuming getConfigurations is a method in AuthService now
    return authService.getConfigurations().then((response) {
      if (response['success'] == true) {
        return response['data'] as List<dynamic>;
      } else {
        throw Exception('Failed to load configurations: ${response['error']}');
      }
    });
  }

  Future<void> _deleteConfig(int configId) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final response = await authService.deleteConfiguration(configId);

    if (mounted) {
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration deleted successfully!'), backgroundColor: Colors.green),
        );
        setState(() {
          _configsFuture = _fetchConfigs();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response['error']}'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }
  
  void _showDeleteConfirmation(int configId, String configName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete the configuration named "$configName"? This action cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteConfig(configId);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load & Manage Configurations'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _configsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Theme.of(context).colorScheme.error)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('You have no saved configurations yet.'));
          }
          final configs = snapshot.data!;
          return ListView.builder(
            itemCount: configs.length,
            itemBuilder: (ctx, index) {
              final config = configs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(config['name'] ?? 'Untitled Configuration'),
                  subtitle: Text(
                    config['userGoal'] ?? 'No goal specified.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    final sessionService = Provider.of<PromptSessionService>(context, listen: false);
                    sessionService.loadFromMap(config);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ReviewPromptScreen(),
                        ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Theme.of(context).colorScheme.error,
                    tooltip: 'Delete Configuration',
                    onPressed: () => _showDeleteConfirmation(config['id'], config['name']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}