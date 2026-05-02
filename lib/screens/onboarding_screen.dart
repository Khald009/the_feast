import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subject.dart';
import '../providers/subject_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int subjectCount = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Get Started')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('How many subjects do you want to study?',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            Slider.adaptive(
              value: subjectCount.toDouble(),
              min: 1,
              max: 6,
              divisions: 5,
              label: '$subjectCount',
              onChanged: (value) {
                setState(() {
                  subjectCount = value.toInt();
                });
              },
            ),
            const SizedBox(height: 16),
            Text('Subject pages: $subjectCount',
                style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            ElevatedButton(
              onPressed: _createSubjects,
              child: const Text('Create Subjects'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createSubjects() async {
    final subjects = List.generate(subjectCount, (index) {
      return Subject(
        id: '${DateTime.now().toIso8601String()}_$index',
        name: 'Subject ${index + 1}',
        description: 'Your subject ${index + 1} description',
        createdAt: DateTime.now(),
      );
    });

    for (final subject in subjects) {
      await ref.read(subjectProvider.notifier).addSubject(subject);
    }
  }
}
