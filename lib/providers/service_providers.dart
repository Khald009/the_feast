import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/ai_processing_service.dart';
import '../core/content_processing_service.dart';
import '../core/ocr_service.dart';
import '../core/tts_service.dart';
import '../core/translation_service.dart';

final contentProcessingServiceProvider = Provider<ContentProcessingService>(
  (ref) => MockContentProcessingService(),
);

final ocrServiceProvider = Provider<OCRService>(
  (ref) => MockOCRService(),
);

final ttsServiceProvider = Provider<TTSService>(
  (ref) => MockTTSService(),
);

final aiProcessingServiceProvider = Provider<AIProcessingService>(
  (ref) => MockAIProcessingService(),
);

final translationServiceProvider = Provider<TranslationService>(
  (ref) => MockTranslationService(),
);
