import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/lecture_provider.dart';
import '../providers/subject_provider.dart';
import '../providers/derived_providers.dart';
import '../models/subject.dart';
import '../core/navigation/navigation_helper.dart';

class StudyOverviewScreen extends ConsumerWidget {
  const StudyOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lectures = ref.watch(lectureProvider);
    final subjects = ref.watch(subjectProvider);

    if (lectures.isEmpty) {
      return const Center(
        child: Text('No lectures available yet.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        itemCount: lectures.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final lecture = lectures[index];
          final subject = subjects.firstWhere(
            (subject) => subject.id == lecture.subjectId,
            orElse: () => Subject(
                id: lecture.subjectId,
                name: 'Unknown',
                description: '',
                createdAt: DateTime.now()),
          );
          final lectureProgress =
              ref.watch(lectureProgressProvider(lecture.id));
          final progress = lectureProgress?.progress ?? 0.0;

          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                NavigationHelper.openLectureScreen(context, subject);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lecture.title,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(subject.name,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${(progress * 100).round()}% complete',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            NavigationHelper.openLectureScreen(
                                context, subject);
                          },
                          child: const Text('Open'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
