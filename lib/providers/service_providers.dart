import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/ai_processing_service.dart';
import '../core/content_processing_service.dart';
import '../core/ocr_service.dart';
import '../core/tts_service.dart';
import '../core/translation_service.dart';

// Configuration for AI services
class AIServiceConfig {
  final String openAIApiKey;
  final String model;

  const AIServiceConfig({
    required this.openAIApiKey,
    this.model = 'gpt-4o-mini',
  });
}

// Provider for secure storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Provider for AI service configuration
final aiServiceConfigProvider = FutureProvider<AIServiceConfig>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  final apiKey = await storage.read(key: 'openai_api_key') ?? '';
  final model = await storage.read(key: 'openai_model') ?? 'gpt-4o-mini';
  return AIServiceConfig(openAIApiKey: apiKey, model: model);
});

final contentProcessingServiceProvider = Provider<ContentProcessingService>(
  (ref) => MockContentProcessingService(),
);

final ocrServiceProvider = FutureProvider<OCRService>((ref) async {
  final aiService = await ref.watch(aiProcessingServiceProvider.future);
  return GoogleMLKitOCRService(aiService);
});

final ttsServiceProvider = Provider<TTSService>(
  (ref) => MockTTSService(),
);

final aiProcessingServiceProvider = FutureProvider<AIProcessingService>((ref) async {
  final configAsync = ref.watch(aiServiceConfigProvider);
  return configAsync.maybeWhen(
    data: (config) {
      if (config.openAIApiKey.isNotEmpty) {
        return OpenAIProcessingService(
          apiKey: config.openAIApiKey,
          model: config.model,
        );
      } else {
        // Fallback to mock service if no API key is configured
        return MockAIProcessingService();
      }
    },
    orElse: () => MockAIProcessingService(),
  );
});

final translationServiceProvider = Provider<TranslationService>(
  (ref) => MockTranslationService(),
);
