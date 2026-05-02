abstract class OCRService {
  Future<String?> extractTextFromImage(String filePath);
  Future<bool> hasDocumentText(String filePath);
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
