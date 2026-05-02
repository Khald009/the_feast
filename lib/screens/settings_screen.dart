import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final apiKey = await _storage.read(key: 'openai_api_key') ?? '';
    setState(() {
      _apiKeyController.text = apiKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'AI Configuration',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'OpenAI API Key',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureApiKey,
            decoration: InputDecoration(
              hintText: 'sk-...',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureApiKey ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureApiKey = !_obscureApiKey;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get your API key from https://platform.openai.com/api-keys',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('Save Settings'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Note: API key is stored securely on your device. Restart the app after saving.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    await _storage.write(key: 'openai_api_key', value: _apiKeyController.text);
    await _storage.write(key: 'openai_model', value: 'gpt-4o-mini');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved! Please restart the app.'),
        ),
      );
    }
  }
}
