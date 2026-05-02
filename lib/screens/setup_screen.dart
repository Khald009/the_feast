import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subject.dart';
import '../providers/subject_provider.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final TextEditingController _subjectCountController = TextEditingController();
  final List<TextEditingController> _subjectNameControllers = [];
  bool _isConfigured = false;

  @override
  void initState() {
    super.initState();
    _checkExistingSubjects();
  }

  @override
  void dispose() {
    _subjectCountController.dispose();
    for (final controller in _subjectNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _checkExistingSubjects() async {
    final subjects = ref.read(subjectProvider);
    if (subjects.isNotEmpty) {
      setState(() {
        _isConfigured = true;
      });
    }
  }

  void _onSubjectCountChanged(String value) {
    final count = int.tryParse(value) ?? 0;
    setState(() {
      // Clear existing controllers
      for (final controller in _subjectNameControllers) {
        controller.dispose();
      }
      _subjectNameControllers.clear();

      // Create new controllers
      for (var i = 0; i < count; i++) {
        _subjectNameControllers.add(TextEditingController());
      }
    });
  }

  Future<void> _saveSubjects() async {
    final subjectNotifier = ref.read(subjectProvider.notifier);

    for (var i = 0; i < _subjectNameControllers.length; i++) {
      final name = _subjectNameControllers[i].text.trim();
      if (name.isNotEmpty) {
        final subject = Subject(
          id: '${DateTime.now().millisecondsSinceEpoch}_$i',
          name: name,
          description: 'Subject ${i + 1}',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await subjectNotifier.addSubject(subject);
      }
    }

    setState(() {
      _isConfigured = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subjects configured successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isConfigured) {
      return _buildConfiguredView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Subjects'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to The Feast!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Let\'s set up your study subjects to get started.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _subjectCountController,
              decoration: const InputDecoration(
                labelText: 'Number of Subjects',
                hintText: 'Enter the number of subjects you want to study',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: _onSubjectCountChanged,
            ),
            const SizedBox(height: 24),
            if (_subjectNameControllers.isNotEmpty) ...[
              Text(
                'Subject Names:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _subjectNameControllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: TextField(
                        controller: _subjectNameControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Subject ${index + 1} Name',
                          hintText: 'Enter subject name',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSaveSubjects() ? _saveSubjects : null,
                  child: const Text('Save Subjects'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfiguredView() {
    final subjects = ref.watch(subjectProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects Configured'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => setState(() => _isConfigured = false),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Study Subjects',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: subjects.isEmpty
                  ? const Center(child: Text('No subjects configured'))
                  : ListView.builder(
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjects[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            title: Text(subject.name),
                            subtitle: Text(subject.description),
                            trailing: Text(
                              '${subject.lecturesCount} lectures',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/home'),
                child: const Text('Start Studying'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canSaveSubjects() {
    if (_subjectNameControllers.isEmpty) return false;
    return _subjectNameControllers
        .every((controller) => controller.text.trim().isNotEmpty);
  }
}
