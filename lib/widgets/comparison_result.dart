import 'package:flutter/material.dart';
import '../core/study_engine.dart';

/// Displays the comparison result after user submission
/// Shows word-by-word accuracy feedback
class ComparisonResult extends StatelessWidget {
  final List<WordComparison> comparisons;
  final double accuracy;

  const ComparisonResult({
    super.key,
    required this.comparisons,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    if (comparisons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _getFeedbackMessage(),
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: _getFeedbackColor()),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: comparisons.map((comparison) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      comparison.correct ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: comparison.correct ? Colors.green : Colors.red,
                  ),
                ),
                child: Text(
                  comparison.typedWord ?? '',
                  style: TextStyle(
                    color: comparison.correct
                        ? Colors.green[900]
                        : Colors.red[900],
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getFeedbackMessage() {
    if (accuracy >= 0.9) {
      return 'Excellent! 🎉 (${(accuracy * 100).toStringAsFixed(0)}%)';
    }
    if (accuracy >= 0.7) {
      return 'Good! Keep practicing (${(accuracy * 100).toStringAsFixed(0)}%)';
    }
    return 'Needs Improvement. Try again (${(accuracy * 100).toStringAsFixed(0)}%)';
  }

  Color _getFeedbackColor() {
    if (accuracy >= 0.9) return Colors.green;
    if (accuracy >= 0.7) return Colors.blue;
    return Colors.orange;
  }

  Color _getBackgroundColor() {
    if (accuracy >= 0.9) return Colors.green[50] ?? Colors.white;
    if (accuracy >= 0.7) return Colors.blue[50] ?? Colors.white;
    return Colors.orange[50] ?? Colors.white;
  }

  Color _getBorderColor() {
    if (accuracy >= 0.9) return Colors.green[300] ?? Colors.green;
    if (accuracy >= 0.7) return Colors.blue[300] ?? Colors.blue;
    return Colors.orange[300] ?? Colors.orange;
  }
}
