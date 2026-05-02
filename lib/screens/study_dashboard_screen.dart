import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subject_provider.dart';
import '../providers/lecture_provider.dart';

class StudyDashboardScreen extends ConsumerWidget {
  const StudyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectProvider);
    final lectures = ref.watch(lectureProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Study Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: subjects.isEmpty
            ? const Center(
                child: Text('Add a subject to begin your study journey.'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Subjects',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: subjects.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final subject = subjects[index];
                        final subjectLectures = lectures
                            .where((lecture) => lecture.subjectId == subject.id)
                            .toList();
                        return Card(
                          child: ListTile(
                            title: Text(subject.name),
                            subtitle:
                                Text('${subjectLectures.length} lectures'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
