abstract class TranslationService {
  Future<String> translate(String text, String fromLocale, String toLocale);
}

class MockTranslationService implements TranslationService {
  @override
  Future<String> translate(
      String text, String fromLocale, String toLocale) async {
    return '$text ($toLocale)';
  }
}
