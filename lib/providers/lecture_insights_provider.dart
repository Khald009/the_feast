import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/ai_processing_service.dart';
import '../models/lecture.dart';
import '../models/content.dart';
import 'derived_providers.dart';
import 'service_providers.dart';

final lectureInsightsProvider =
    FutureProvider.family<LectureInsights, Lecture>((ref, lecture) async {
  final contents = ref.watch(contentsByLectureProvider(lecture.id));
  final contentService = ref.read(contentProcessingServiceProvider);
  final aiService = ref.read(aiProcessingServiceProvider);

  final rawText = contents
      .where((c) => c.type == ContentType.text)
      .map((c) => c.data)
      .join(' ');

  if (rawText.isEmpty) {
    return LectureInsights(shortSummary: '', keySentences: [], sections: []);
  }

  final normalized = await contentService.normalizeText(rawText);
  return aiService.generateInsights(normalized);
});
