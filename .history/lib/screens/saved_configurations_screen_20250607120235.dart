// lib/screens/saved_configurations_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artisan_ai/services/auth_service.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class SavedConfigurationsScreen extends StatefulWidget {
  const SavedConfigurationsScreen({super.key});

  @override
  State<SavedConfigurationsScreen> createState() => _SavedConfigurationsScreenState();
}

class _SavedConfigurationsScreenState extends State<SavedConfigurationsScreen> {
  late Future<List<dynamic>> _configsFuture;

  @override
  void initState() {
    super.initState();
    _configsFuture = _fetchConfigs();
  }

  Future<List<dynamic>> _fetchConfigs() {
    // listen: false because this is in initState
    final authService = Provider.of<AuthService>(context, listen: false);
    return authService.getConfigurations().then((response) {
      if (response['success'] == true) {
        return response['data'] as List<dynamic>;
      } else {
        // Propagate the error to be handled by the FutureBuilder
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
        // Refresh the list after deletion
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
              Navigator.of(ctx).pop(); // Close the dialog
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
        title: const Text('Saved Configurations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh List',
            onPressed: () {
              setState(() {
                _configsFuture = _fetchConfigs();
              });
            },
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _configsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error}', 
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              )
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'You have no saved configurations yet.\nGo back and use the "Save Config" button on the review screen to save your first one!',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final configs = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _fetchConfigs,
            child: ListView.builder(
              itemCount: configs.length,
              itemBuilder: (ctx, index) {
                final config = configs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(config['name'] ?? 'Untitled Configuration'),
                    subtitle: Text(
                      config['userGoal'] ?? 'No goal specified.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      // TODO: Implement loading the configuration into the flow
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Loading "${config['name']}" - To be implemented!')),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Theme.of(context).colorScheme.error.withOpacity(0.7),
                      tooltip: 'Delete Configuration',
                      onPressed: () => _showDeleteConfirmation(config['id'], config['name'] ?? 'this configuration'),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}