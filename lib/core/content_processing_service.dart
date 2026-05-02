import '../models/content.dart';

abstract class ContentProcessingService {
  Future<String> extractText(Content content);
  Future<String> normalizeText(String rawText);
  Future<List<String>> splitIntoSentences(String text);
  Future<List<String>> extractKeySentences(String text);
  Future<Map<String, dynamic>> analyzeContent(Content content);
}

class MockContentProcessingService implements ContentProcessingService {
  @override
  Future<String> extractText(Content content) async {
    if (content.type == ContentType.text) {
      return content.data.trim();
    }
    // Simulate PDF text extraction
    if (content.type == ContentType.pdf) {
      return 'Extracted text from PDF: ${content.data}';
    }
    return content.data.trim();
  }

  @override
  Future<Map<String, dynamic>> analyzeContent(Content content) async {
    final rawText = await extractText(content);
    final normalized = await normalizeText(rawText);
    final sentences = await splitIntoSentences(normalized);
    final keySentences = await extractKeySentences(normalized);
    return {
      'rawText': rawText,
      'normalizedText': normalized,
      'sentences': sentences,
      'keySentences': keySentences,
      'contentType': content.type,
    };
  }

  @override
  Future<String> normalizeText(String rawText) async {
    // Remove extra whitespace, normalize line breaks
    return rawText
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\n+'), ' ')
        .trim();
  }

  @override
  Future<List<String>> splitIntoSentences(String text) async {
    // Improved sentence splitting with better regex
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    return sentences
        .map((s) => s.trim())
        .where((s) =>
            s.isNotEmpty && s.length > 5) // Filter out very short fragments
        .toList();
  }

  @override
  Future<List<String>> extractKeySentences(String text) async {
    final sentences = await splitIntoSentences(text);
    if (sentences.isEmpty) return [];

    // Simple heuristic: select sentences longer than average, or containing keywords
    final avgLength = sentences.map((s) => s.length).reduce((a, b) => a + b) /
        sentences.length;
    final keywords = ['important', 'key', 'main', 'essential', 'remember'];

    return sentences.where((sentence) {
      final hasKeyword =
          keywords.any((kw) => sentence.toLowerCase().contains(kw));
      final isLong = sentence.length > avgLength * 1.2;
      return hasKeyword || isLong;
    }).toList();
  }
}
