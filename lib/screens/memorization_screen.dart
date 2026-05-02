import 'package:flutter/material.dart';
import '../core/study_engine.dart';
import '../widgets/comparison_result.dart';

class MemorizationScreen extends StatefulWidget {
  final String sentence;

  const MemorizationScreen({super.key, required this.sentence});

  @override
  State<MemorizationScreen> createState() => _MemorizationScreenState();
}

class _MemorizationScreenState extends State<MemorizationScreen> {
  late TextEditingController _controller;
  List<WordComparison> _comparison = [];
  bool _showComparison = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    if (_showComparison) {
      setState(() {
        _comparison = StudyEngine.compareSentence(widget.sentence, text);
      });
    }
  }

  void _submitAnswer() {
    final text = _controller.text;
    final comparison = StudyEngine.compareSentence(widget.sentence, text);

    setState(() {
      _comparison = comparison;
      _showComparison = true;
    });
  }

  void _speakWithHighlighting() {
    // For now, just simulate
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memorization')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Listen and repeat this sentence',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Text(widget.sentence, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _speakWithHighlighting,
              icon: const Icon(Icons.volume_up),
              label: const Text('Read Aloud'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              onChanged: _onTextChanged,
              decoration: const InputDecoration(labelText: 'Type the sentence'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _controller.text.isNotEmpty ? _submitAnswer : null,
              child: const Text('Submit'),
            ),
            if (_showComparison) ...[
              const SizedBox(height: 16),
              ComparisonResult(
                comparisons: _comparison,
                accuracy: StudyEngine.calculateAccuracy(_comparison),
              ),
              const SizedBox(height: 8),
              Text('Accuracy: ${(StudyEngine.calculateAccuracy(_comparison) * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}