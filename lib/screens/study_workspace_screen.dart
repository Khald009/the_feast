import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subject_provider.dart';
import '../providers/lecture_provider.dart';
import '../providers/user_progress_provider.dart';
import '../models/subject.dart';
import '../models/lecture.dart';
import '../models/user_progress.dart';
import '../core/navigation/navigation_helper.dart';

class StudyWorkspaceScreen extends ConsumerWidget {
  const StudyWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectProvider);
    final lectures = ref.watch(lectureProvider);
    final progress = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Workspace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSubjectDialog(context, ref),
          ),
        ],
      ),
      body: subjects.isEmpty
          ? _buildEmptyState(context, ref)
          : _buildWorkspaceContent(context, subjects, lectures, progress),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Welcome to Smart Study!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first subject to begin',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddSubjectDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add Subject'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceContent(
    BuildContext context,
    List<Subject> subjects,
    List<Lecture> lectures,
    List<UserProgress> progress,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Your Subjects', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        ...subjects.map((subject) =>
            _buildSubjectCard(context, subject, lectures, progress)),
      ],
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    Subject subject,
    List<Lecture> lectures,
    List<UserProgress> progress,
  ) {
    final subjectLectures =
        lectures.where((l) => l.subjectId == subject.id).toList();
    final subjectProgress = progress
        .where((p) => subjectLectures.any((l) => l.id == p.lectureId))
        .toList();

    final accuracies = subjectProgress
        .map((p) => p.sentenceAccuracies?.values ?? [])
        .expand((values) => values)
        .toList();

    final avgAccuracy = accuracies.isNotEmpty
        ? accuracies.reduce((a, b) => a + b) / accuracies.length
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => NavigationHelper.openLectureScreen(context, subject),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(subject.name,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Text('${subjectLectures.length} lectures'),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: avgAccuracy,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation(
                  avgAccuracy > 0.8
                      ? Colors.green
                      : avgAccuracy > 0.6
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text('Avg Accuracy: ${(avgAccuracy * 100).toStringAsFixed(1)}%'),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subject'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Subject Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(subjectProvider.notifier).addSubject(
                  Subject(
                    id: DateTime.now().toString(),
                    name: controller.text,
                    description: '',
                    createdAt: DateTime.now(),
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
