import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subject.dart';
import '../models/lecture.dart';
import '../models/content.dart';
import '../models/mistake.dart';
import '../providers/lecture_provider.dart';
import '../providers/content_provider.dart';
import '../providers/mistake_provider.dart';
import '../providers/user_progress_provider.dart';
import '../providers/derived_providers.dart';
import '../core/navigation/navigation_helper.dart';

class LectureScreen extends ConsumerWidget {
  final Subject subject;

  const LectureScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lectures = ref.watch(lecturesBySubjectProvider(subject.id));

    return Scaffold(
      appBar: AppBar(title: Text(subject.name)),
      body: lectures.isEmpty
          ? const SizedBox.expand(
              child: Center(
                child: Text('No lectures yet. Add one!'),
              ),
            )
          : ListView.builder(
              itemCount: lectures.length,
              itemBuilder: (context, index) {
                final lecture = lectures[index];
                final lectureContents =
                    ref.watch(textContentsByLectureProvider(lecture.id));
                final lectureMistakes =
                    ref.watch(lectureMistakesProvider(lecture.id));
                final lectureProgress =
                    ref.watch(lectureProgressProvider(lecture.id));
                return ExpansionTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lecture.title),
                      const SizedBox(height: 4),
                      Text(
                        'Progress: ${((lectureProgress?.progress ?? 0) * 100).round()}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                          value: lectureProgress?.progress ?? 0),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await ref
                          .read(lectureProvider.notifier)
                          .deleteLecture(lecture.id);
                    },
                  ),
                  children: [
                    if (lectureContents.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No text content yet.'),
                      )
                    else
                      ...lectureContents.map((content) => ListTile(
                            title: Text(content.data),
                            subtitle: const Text('Text Content'),
                            onTap: () async {
                              if (lectureContents.isNotEmpty) {
                                final increment = 1.0 / lectureContents.length;
                                await ref
                                    .read(userProgressProvider.notifier)
                                    .updateProgress(lecture.id, increment);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Progress updated')),
                                  );
                                }
                              }
                            },
                            trailing: IconButton(
                              icon: const Icon(Icons.flag),
                              tooltip: 'Mark as Mistake',
                              onPressed: () => _showMarkMistakeDialog(
                                  context, ref, lecture.id, content.data),
                            ),
                          )),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () =>
                            _showAddContentDialog(context, ref, lecture.id),
                        child: const Text('Add Text Content'),
                      ),
                    ),
                    if (lectureContents.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            NavigationHelper.openStudyScreen(
                                context, lecture, lectureContents);
                          },
                          child: const Text('Study Mode'),
                        ),
                      ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Mistakes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (lectureMistakes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text('No mistakes tracked for this lecture.'),
                      )
                    else
                      ...lectureMistakes.map((mistake) => ListTile(
                            title: Text(mistake.description),
                            subtitle: Text(
                                'Added: ${mistake.date.toLocal().toIso8601String()}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                await ref
                                    .read(mistakeProvider.notifier)
                                    .deleteMistake(mistake.id);
                              },
                            ),
                          )),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        tooltip: 'Add Lecture',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Lecture'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Lecture Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                final lecture = Lecture(
                  id: DateTime.now().toString(),
                  subjectId: subject.id,
                  lectureNumber: ref.read(lectureProvider).where((l) => l.subjectId == subject.id).length + 1,
                  lectureName: titleController.text,
                  sourceContent: '',
                  contentIds: [],
                  createdAt: DateTime.now(),
                );
                await ref.read(lectureProvider.notifier).addLecture(lecture);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddContentDialog(
      BuildContext context, WidgetRef ref, String lectureId) {
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Text Content'),
        content: TextField(
          controller: contentController,
          decoration: const InputDecoration(labelText: 'Text Content'),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (contentController.text.isNotEmpty) {
                final content = Content(
                  id: DateTime.now().toString(),
                  lectureId: lectureId,
                  type: ContentType.text,
                  data: contentController.text,
                  createdAt: DateTime.now(),
                );
                await ref.read(contentProvider.notifier).addContent(content);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showMarkMistakeDialog(
    BuildContext context,
    WidgetRef ref,
    String lectureId,
    String sentence,
  ) {
    final mistakeController = TextEditingController(text: sentence);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Mistake'),
        content: TextField(
          controller: mistakeController,
          decoration: const InputDecoration(labelText: 'Mistake description'),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (mistakeController.text.isNotEmpty) {
                final mistake = Mistake(
                  id: DateTime.now().toString(),
                  lectureId: lectureId,
                  description: mistakeController.text,
                  correction: null,
                  date: DateTime.now(),
                );
                await ref.read(mistakeProvider.notifier).addMistake(mistake);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
