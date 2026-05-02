class LectureInsights {
  final String shortSummary;
  final List<String> keySentences;
  final List<String> sections;

  LectureInsights({
    required this.shortSummary,
    required this.keySentences,
    required this.sections,
  });
}

abstract class AIProcessingService {
  Future<LectureInsights> generateInsights(String text);
  Future<String> generateSummary(String text);
  Future<List<String>> extractKeySentences(String text);
  Future<List<String>> extractSections(String text);
}

class MockAIProcessingService implements AIProcessingService {
  @override
  Future<LectureInsights> generateInsights(String text) async {
    final summary = await generateSummary(text);
    final sentences = await extractKeySentences(text);
    final sections = await extractSections(text);
    return LectureInsights(
      shortSummary: summary,
      keySentences: sentences,
      sections: sections,
    );
  }

  @override
  Future<String> generateSummary(String text) async {
    final sentences = text.split('.').where((s) => s.trim().isNotEmpty);
    if (sentences.isEmpty) return 'No content available';
    final first = sentences.first.trim();
    final last = sentences.length > 1 ? sentences.last.trim() : '';
    return 'Summary: $first${last.isNotEmpty ? ' ... $last' : ''}';
  }

  @override
  Future<List<String>> extractKeySentences(String text) async {
    final sentences =
        text.split('.').where((s) => s.trim().isNotEmpty).toList();
    if (sentences.isEmpty) return [];

    // Select sentences with keywords or longer than average
    final avgLength = sentences.map((s) => s.length).reduce((a, b) => a + b) /
        sentences.length;
    final keywords = [
      'important',
      'key',
      'main',
      'essential',
      'remember',
      'note'
    ];

    return sentences
        .where((sentence) {
          final hasKeyword =
              keywords.any((kw) => sentence.toLowerCase().contains(kw));
          final isLong = sentence.length > avgLength;
          return hasKeyword || isLong;
        })
        .take(5)
        .toList();
  }

  @override
  Future<List<String>> extractSections(String text) async {
    // Simulate section detection
    final sentences =
        text.split('.').where((s) => s.trim().isNotEmpty).toList();
    if (sentences.isEmpty) return ['Overview'];

    final sections = <String>[];
    sections.add('Introduction');
    if (sentences.length >= 3) sections.add('Key Concepts');
    if (sentences.length >= 5) sections.add('Examples');
    if (sentences.length >= 7) sections.add('Summary');

    return sections;
  }
}
