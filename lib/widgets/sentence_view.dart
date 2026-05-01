import 'package:flutter/material.dart';

/// Displays the sentence to be memorized
/// Shows in a styled container for clear readability
class SentenceView extends StatelessWidget {
  final String sentence;

  const SentenceView({
    super.key,
    required this.sentence,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Text(
          sentence,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
