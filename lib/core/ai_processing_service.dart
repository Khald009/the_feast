import 'package:openai_dart/openai_dart.dart';
import 'dart:convert';

class LectureInsights {
  final String shortSummary;
  final List<String> keySentences;
  final List<String> sections;
  final Map<String, double> sentenceDifficulties;
  final List<String> recommendedStudyOrder;

  LectureInsights({
    required this.shortSummary,
    required this.keySentences,
    required this.sections,
    this.sentenceDifficulties = const {},
    this.recommendedStudyOrder = const [],
  });
}

abstract class AIProcessingService {
  Future<LectureInsights> generateInsights(String text);
  Future<String> generateSummary(String text);
  Future<List<String>> extractKeySentences(String text);
  Future<List<String>> extractSections(String text);
  Future<Map<String, double>> calculateSentenceDifficulties(String text);
  Future<List<String>> recommendStudyOrder(String text, Map<String, double> userPerformance);

  // Error handling
  Future<bool> isServiceAvailable();
  Future<void> initializeService();
}

class MockAIProcessingService implements AIProcessingService {
  @override
  Future<LectureInsights> generateInsights(String text) async {
    final summary = await generateSummary(text);
    final sentences = await extractKeySentences(text);
    final sections = await extractSections(text);
    final difficulties = await calculateSentenceDifficulties(text);
    final studyOrder = await recommendStudyOrder(text, {});
    return LectureInsights(
      shortSummary: summary,
      keySentences: sentences,
      sections: sections,
      sentenceDifficulties: difficulties,
      recommendedStudyOrder: studyOrder,
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

  @override
  Future<Map<String, double>> calculateSentenceDifficulties(String text) async {
    final sentences = text.split('.').where((s) => s.trim().isNotEmpty).toList();
    final difficulties = <String, double>{};

    for (final sentence in sentences) {
      final words = sentence.split(' ');
      final difficulty = (words.length / 20.0).clamp(0.1, 1.0);
      difficulties[sentence] = difficulty;
    }

    return difficulties;
  }

  @override
  Future<List<String>> recommendStudyOrder(String text, Map<String, double> userPerformance) async {
    final sentences = text.split('.').where((s) => s.trim().isNotEmpty).toList();

    sentences.sort((a, b) {
      final aPerf = userPerformance[a] ?? 1.0;
      final bPerf = userPerformance[b] ?? 1.0;
      return aPerf.compareTo(bPerf); // Worse performance first
    });

    return sentences;
  }

  @override
  Future<bool> isServiceAvailable() async => true;

  @override
  Future<void> initializeService() async {}
}

class OpenAIProcessingService implements AIProcessingService {
  final OpenAIClient _client;
  final String _model;

  OpenAIProcessingService({
    required String apiKey,
    String model = 'gpt-4o-mini',
  }) : _client = OpenAIClient(apiKey: apiKey),
       _model = model;

  @override
  Future<LectureInsights> generateInsights(String text) async {
    final prompt = '''
You are a highly efficient Educational AI Integrator. Your task is to analyze the provided text and return a structured JSON response that will be parsed by a Flutter application.

CONSTRAINTS:
1. Return ONLY a valid JSON object. Do not include any conversational text, markdown formatting like ```json, or explanations.
2. If the text is unclear, provide the best possible analysis based on available content.
3. Use the exact keys specified in the schema below.

ANALYSIS REQUIREMENTS:
1. SUMMARY: A clear 2-3 sentence overview of the core message.
2. KEY SENTENCES: Identify the top 3-5 most important sentences for understanding the topic.
3. SECTIONS: Breakdown the text into logical chapters or topics with titles.
4. DIFFICULTY: A score between 0.1 (very easy) and 1.0 (highly technical/complex).
5. STUDY ORDER: A recommended step-by-step sequence to learn these concepts effectively.

OUTPUT SCHEMA (JSON):
{
  "summary": "String",
  "key_sentences": ["String", "String", "String"],
  "sections": [
    {"title": "String", "content_preview": "String"}
  ],
  "difficulty_score": 0.0,
  "study_order": [
    {"step": 1, "topic": "String", "reason": "String"}
  ]
}

INPUT TEXT:
$text
''';

    final response = await _client.createChatCompletion(
      request: CreateChatCompletionRequest(
        model: ChatCompletionModel.modelId(_model),
        messages: [
          ChatCompletionMessage.user(
            content: ChatCompletionUserMessageContent.string(prompt),
          ),
        ],
        maxTokens: 1500,
        temperature: 0.3,
      ),
    );

    final content = response.choices.first.message.content?.toString() ?? '{}';
    
    try {
      final jsonResponse = json.decode(content) as Map<String, dynamic>;
      
      // Extract sections titles for backward compatibility
      final sections = (jsonResponse['sections'] as List?)
          ?.map((s) => (s as Map<String, dynamic>)['title'] as String)
          .toList() ?? [];
      
      // Convert study order to simple strings for backward compatibility
      final studyOrder = (jsonResponse['study_order'] as List?)
          ?.map((s) => (s as Map<String, dynamic>)['topic'] as String)
          .toList() ?? [];
      
      // Create sentence difficulties map (simplified)
      final difficulty = jsonResponse['difficulty_score'] as double? ?? 0.5;
      final keySentences = (jsonResponse['key_sentences'] as List?)
          ?.map((s) => s as String)
          .toList() ?? [];
      
      final sentenceDifficulties = <String, double>{};
      for (final sentence in keySentences) {
        sentenceDifficulties[sentence] = difficulty;
      }
      
      return LectureInsights(
        shortSummary: jsonResponse['summary'] as String? ?? 'Unable to generate summary',
        keySentences: keySentences,
        sections: sections,
        sentenceDifficulties: sentenceDifficulties,
        recommendedStudyOrder: studyOrder,
      );
    } catch (e) {
      // Fallback to individual method calls
      final summary = await generateSummary(text);
      final sentences = await extractKeySentences(text);
      final sections = await extractSections(text);
      final difficulties = await calculateSentenceDifficulties(text);
      final studyOrder = await recommendStudyOrder(text, {});
      return LectureInsights(
        shortSummary: summary,
        keySentences: sentences,
        sections: sections,
        sentenceDifficulties: difficulties,
        recommendedStudyOrder: studyOrder,
      );
    }
  }

  @override
  Future<String> generateSummary(String text) async {
    final prompt = '''
Analyze the following educational content and provide a structured JSON response.

CONTENT:
$text

Return ONLY a valid JSON object with this exact schema:
{
  "summary": "A clear 2-3 sentence overview of the core message",
  "key_sentences": ["Top 3-5 most important sentences"],
  "sections": [
    {"title": "Section Title", "content_preview": "Brief description"}
  ],
  "difficulty_score": 0.5,
  "study_order": [
    {"step": 1, "topic": "Topic name", "reason": "Why study this first"}
  ]
}

JSON:''';

    final response = await _client.createChatCompletion(
      request: CreateChatCompletionRequest(
        model: ChatCompletionModel.modelId(_model),
        messages: [
          ChatCompletionMessage.user(
            content: ChatCompletionUserMessageContent.string(prompt),
          ),
        ],
        maxTokens: 1000,
        temperature: 0.3,
      ),
    );

    final content = response.choices.first.message.content?.toString() ?? '{}';
    try {
      final jsonResponse = json.decode(content);
      return jsonResponse['summary'] ?? 'Unable to generate summary';
    } catch (e) {
      // Fallback to simple extraction
      return content.split('"summary":')[1]?.split('"')[1] ?? 'Unable to generate summary';
    }
  }

  @override
  Future<List<String>> extractKeySentences(String text) async {
    // Use the same comprehensive analysis as generateSummary
    final summaryResponse = await generateSummary(text);
    // Since generateSummary now returns structured JSON, we need to parse it
    // But for backward compatibility, let's create a separate method
    final prompt = '''
Extract the 3-5 most important sentences from the following educational content. Return as JSON array:

$text

Return ONLY: ["sentence1", "sentence2", "sentence3"]

JSON:''';

    final response = await _client.createChatCompletion(
      request: CreateChatCompletionRequest(
        model: ChatCompletionModel.modelId(_model),
        messages: [
          ChatCompletionMessage.user(
            content: ChatCompletionUserMessageContent.string(prompt),
          ),
        ],
        maxTokens: 300,
        temperature: 0.2,
      ),
    );

    final content = response.choices.first.message.content?.toString() ?? '[]';
    try {
      final sentences = json.decode(content) as List;
      return sentences.map((s) => s.toString()).toList();
    } catch (e) {
      // Fallback
      return content.split('"').where((s) => s.trim().isNotEmpty && s.length > 10).take(5).toList();
    }
  }

  @override
  Future<List<String>> extractSections(String text) async {
    final prompt = '''
Analyze the following educational content and identify the main sections or topics. Return a list of section titles that would be appropriate for a table of contents:

$text

Sections (one per line):''';

    final response = await _client.createChatCompletion(
      request: CreateChatCompletionRequest(
        model: ChatCompletionModel.modelId(_model),
        messages: [
          ChatCompletionMessage.user(
            content: ChatCompletionUserMessageContent.string(prompt),
          ),
        ],
        maxTokens: 200,
        temperature: 0.2,
      ),
    );

    final content = response.choices.first.message.content?.toString() ?? '';
    final sections = content.split('\n').where((s) => s.trim().isNotEmpty).toList();
    return sections.isNotEmpty ? sections : ['Overview'];
  }

  @override
  Future<Map<String, double>> calculateSentenceDifficulties(String text) async {
    final sentences = text.split('.').where((s) => s.trim().isNotEmpty).toList();
    final difficulties = <String, double>{};

    // Process sentences in batches to avoid token limits
    const batchSize = 10;
    for (var i = 0; i < sentences.length; i += batchSize) {
      final batch = sentences.sublist(i, i + batchSize > sentences.length ? sentences.length : i + batchSize);

      final prompt = '''
Rate the difficulty of each sentence on a scale from 0.1 (very easy) to 1.0 (very difficult) based on vocabulary complexity, sentence structure, and conceptual difficulty. Return as JSON with sentence as key and difficulty as value.

Sentences:
${batch.map((s) => '"$s"').join('\n')}

JSON response:''';

      try {
        final response = await _client.createChatCompletion(
          request: CreateChatCompletionRequest(
            model: ChatCompletionModel.modelId(_model),
            messages: [
              ChatCompletionMessage.user(
                content: ChatCompletionUserMessageContent.string(prompt),
              ),
            ],
            maxTokens: 500,
            temperature: 0.1,
          ),
        );

        final content = response.choices.first.message.content?.toString() ?? '{}';
        final jsonStart = content.indexOf('{');
        final jsonEnd = content.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1) {
          final jsonStr = content.substring(jsonStart, jsonEnd + 1);
          final Map<String, dynamic> parsed = json.decode(jsonStr);
          for (final entry in parsed.entries) {
            if (entry.value is num) {
              difficulties[entry.key] = (entry.value as num).toDouble().clamp(0.1, 1.0);
            }
          }
        }
      } catch (e) {
        // Fallback to simple heuristic
        for (final sentence in batch) {
          final words = sentence.split(' ');
          final difficulty = (words.length / 20.0).clamp(0.1, 1.0);
          difficulties[sentence] = difficulty;
        }
      }
    }

    return difficulties;
  }

  @override
  Future<List<String>> recommendStudyOrder(String text, Map<String, double> userPerformance) async {
    final sentences = text.split('.').where((s) => s.trim().isNotEmpty).toList();

    if (userPerformance.isEmpty) {
      // No performance data, use AI to determine logical study order
      final prompt = '''
Arrange the following sentences in the optimal order for studying this educational content. Consider logical flow, building concepts from simple to complex, and prerequisite knowledge:

${sentences.map((s) => '"$s"').join('\n')}

Recommended order (one sentence per line):''';

      final response = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(_model),
          messages: [
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(prompt),
            ),
          ],
          maxTokens: 500,
          temperature: 0.2,
        ),
      );

      final content = response.choices.first.message.content?.toString() ?? '';
      return content.split('\n').where((s) => s.trim().isNotEmpty).toList();
    } else {
      // Use performance data to prioritize difficult sentences user struggles with
      sentences.sort((a, b) {
        final aPerf = userPerformance[a] ?? 1.0;
        final bPerf = userPerformance[b] ?? 1.0;
        return aPerf.compareTo(bPerf); // Worse performance first
      });
      return sentences;
    }
  }

  @override
  Future<bool> isServiceAvailable() async {
    try {
      // Simple test request
      await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(_model),
          messages: const [
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string('Test'),
            ),
          ],
          maxTokens: 5,
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> initializeService() async {
    // OpenAI client doesn't need explicit initialization
  }
}
