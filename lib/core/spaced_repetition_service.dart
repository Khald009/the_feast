import '../models/user_progress.dart';

class SpacedRepetitionItem {
  final String sentence;
  final DateTime lastReviewed;
  final int reviewCount;
  final double easeFactor;
  final int intervalDays;

  SpacedRepetitionItem({
    required this.sentence,
    required this.lastReviewed,
    this.reviewCount = 0,
    this.easeFactor = 2.5,
    this.intervalDays = 1,
  });

  SpacedRepetitionItem copyWith({
    String? sentence,
    DateTime? lastReviewed,
    int? reviewCount,
    double? easeFactor,
    int? intervalDays,
  }) {
    return SpacedRepetitionItem(
      sentence: sentence ?? this.sentence,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      reviewCount: reviewCount ?? this.reviewCount,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
    );
  }
}

class SpacedRepetitionService {
  static const double _minEaseFactor = 1.3;
  static const double _maxEaseFactor = 2.5;

  /// Calculate next review date using SM-2 algorithm
  static DateTime calculateNextReview({
    required SpacedRepetitionItem item,
    required double performanceRating, // 0.0 to 1.0
  }) {
    // Convert performance to quality (0-5 scale)
    final quality = (performanceRating * 5).round();

    // Update ease factor
    double newEaseFactor =
        item.easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    newEaseFactor = newEaseFactor.clamp(_minEaseFactor, _maxEaseFactor);

    // Calculate interval
    int newInterval;
    if (quality < 3) {
      // Failed - reset to 1 day
      newInterval = 1;
    } else if (item.reviewCount == 0) {
      newInterval = 1;
    } else if (item.reviewCount == 1) {
      newInterval = 6;
    } else {
      newInterval = (item.intervalDays * newEaseFactor).round();
    }

    return item.lastReviewed.add(Duration(days: newInterval));
  }

  /// Get items due for review
  static List<SpacedRepetitionItem> getDueItems(
    List<SpacedRepetitionItem> items, {
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    return items
        .where((item) => item.lastReviewed.isBefore(currentTime))
        .toList();
  }

  /// Sort items by priority (overdue first, then by interval)
  static List<SpacedRepetitionItem> sortByPriority(
      List<SpacedRepetitionItem> items) {
    final now = DateTime.now();
    return items.toList()
      ..sort((a, b) {
        final aOverdue = now.difference(a.lastReviewed).inDays - a.intervalDays;
        final bOverdue = now.difference(b.lastReviewed).inDays - b.intervalDays;

        // Sort by overdue days (most overdue first)
        final overdueCompare = bOverdue.compareTo(aOverdue);
        if (overdueCompare != 0) return overdueCompare;

        // Then by interval (longer intervals first)
        return b.intervalDays.compareTo(a.intervalDays);
      });
  }

  /// Convert UserProgress to SpacedRepetitionItems
  static List<SpacedRepetitionItem> fromUserProgress(UserProgress progress) {
    return progress.sentenceAccuracies?.entries.map((entry) {
      final sentence = entry.key;
      final accuracy = entry.value;

      // Estimate review count and ease factor from accuracy
      final reviewCount = accuracy > 0.8
          ? 3
          : accuracy > 0.6
              ? 2
              : 1;
      final easeFactor = accuracy > 0.8
          ? 2.5
          : accuracy > 0.6
              ? 2.0
              : 1.8;

      return SpacedRepetitionItem(
        sentence: sentence,
        lastReviewed: progress.lastStudied,
        reviewCount: reviewCount,
        easeFactor: easeFactor,
        intervalDays: reviewCount * 2, // Rough estimate
      );
    }).toList() ?? [];
  }
}
