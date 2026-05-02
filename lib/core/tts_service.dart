abstract class TTSService {
  Future<void> speak(String text);
  Future<void> speakWithProgress(
      String text, void Function(int wordIndex) onWordSpoken);
  Future<void> stop();
  bool get isAvailable;
  bool get isPlaying;
  int get currentWordIndex;
}

class MockTTSService implements TTSService {
  bool _isPlaying = false;
  int _currentWordIndex = -1;

  @override
  bool get isAvailable => true;

  @override
  bool get isPlaying => _isPlaying;

  @override
  int get currentWordIndex => _currentWordIndex;

  @override
  Future<void> speak(String text) async {
    _isPlaying = true;
    _currentWordIndex = -1;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _isPlaying = false;
    _currentWordIndex = -1;
  }

  @override
  Future<void> speakWithProgress(
      String text, void Function(int wordIndex) onWordSpoken) async {
    _isPlaying = true;
    _currentWordIndex = -1;

    final words =
        text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    for (var i = 0; i < words.length; i++) {
      _currentWordIndex = i;
      onWordSpoken(i);
      await Future<void>.delayed(
          const Duration(milliseconds: 300)); // Simulate word duration
    }

    _isPlaying = false;
    _currentWordIndex = -1;
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
    _currentWordIndex = -1;
  }
}
