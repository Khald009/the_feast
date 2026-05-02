import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_progress_provider.dart';
import '../providers/lecture_provider.dart';
import '../models/lecture.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressItems = ref.watch(userProgressProvider);
    final lectures = ref.watch(lectureProvider);

    if (progressItems.isEmpty) {
      return const Center(
        child: Text('No progress tracked yet.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        itemCount: progressItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final progress = progressItems[index];
          final lecture = lectures.firstWhere(
            (lecture) => lecture.id == progress.lectureId,
            orElse: () => Lecture(
              id: progress.lectureId,
              subjectId: '',
              lectureNumber: 1,
              lectureName: 'Lecture',
              sourceContent: '',
              contentIds: const [],
              createdAt: DateTime.now(),
            ),
          );

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lecture.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: progress.progress),
                  const SizedBox(height: 8),
                  Text('Last accuracy: ${(progress.lastAccuracy * 100).round()}%', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text('Attempts: ${progress.totalAttempts}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
