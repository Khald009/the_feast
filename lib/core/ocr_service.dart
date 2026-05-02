import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'ai_processing_service.dart';

abstract class OCRService {
  Future<String?> extractTextFromImage(String filePath);
  Future<bool> hasDocumentText(String filePath);
}

class GoogleMLKitOCRService implements OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final AIProcessingService _aiService;

  GoogleMLKitOCRService(this._aiService);

  @override
  Future<String?> extractTextFromImage(String filePath) async {
    try {
      final inputImage = InputImage.fromFilePath(filePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isEmpty) {
        return null;
      }

      // Use OpenAI to clean and format the extracted text
      final cleanedText = await _aiService.cleanAndFormatText(recognizedText.text);
      return cleanedText;
    } catch (e) {
      // Remove print in production
      return null;
    }
  }

  @override
  Future<bool> hasDocumentText(String filePath) async {
    final text = await extractTextFromImage(filePath);
    return text != null && text.isNotEmpty;
  }

  void dispose() {
    _textRecognizer.close();
  }
}

class MockOCRService implements OCRService {
  @override
  Future<String?> extractTextFromImage(String filePath) async {
    return 'Mock OCR text from $filePath';
  }

  @override
  Future<bool> hasDocumentText(String filePath) async {
    return true;
  }
}
