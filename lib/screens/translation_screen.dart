import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/study_session_provider.dart';

class TranslationScreen extends ConsumerWidget {
  final String sentence;

  const TranslationScreen({super.key, required this.sentence});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Translation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Original', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(sentence, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            FutureBuilder<String>(
              future: ref
                  .read(studySessionProvider.notifier)
                  .translateSentence('en'),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Text(snapshot.data ?? '',
                    style: Theme.of(context).textTheme.bodyLarge);
              },
            ),
          ],
        ),
      ),
    );
  }
}
