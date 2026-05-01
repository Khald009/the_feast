class UserProgress {
  final String id;
  final String lectureId;
  final double progress; // e.g., 0.0 to 1.0 for completion percentage
  final DateTime lastStudied;
  final int mistakesCount;
  final double lastAccuracy; // Accuracy of last memorization attempt (0.0 to 1.0)
  final int totalAttempts; // Total memorization attempts
  final Map<String, dynamic>? sentenceAccuracies; // Map of sentence to accuracy score (e.g. {"sentence": 0.85})
  final Map<String, dynamic>? additionalData; // For future extensions like spaced repetition intervals

  const UserProgress({
    required this.id,
    required this.lectureId,
    required this.progress,
    required this.lastStudied,
    required this.mistakesCount,
    this.lastAccuracy = 0.0,
    this.totalAttempts = 0,
    this.sentenceAccuracies,
    this.additionalData,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'] as String,
      lectureId: json['lectureId'] as String,
      progress: (json['progress'] as num).toDouble(),
      lastStudied: DateTime.parse(json['lastStudied'] as String),
      mistakesCount: json['mistakesCount'] as int,
      lastAccuracy: (json['lastAccuracy'] as num?)?.toDouble() ?? 0.0,
      totalAttempts: json['totalAttempts'] as int? ?? 0,
      sentenceAccuracies: json['sentenceAccuracies'] as Map<String, dynamic>?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lectureId': lectureId,
      'progress': progress,
      'lastStudied': lastStudied.toIso8601String(),
      'mistakesCount': mistakesCount,
      'lastAccuracy': lastAccuracy,
      'totalAttempts': totalAttempts,
      'sentenceAccuracies': sentenceAccuracies,
      'additionalData': additionalData,
    };
  }

  UserProgress copyWith({
    String? id,
    String? lectureId,
    double? progress,
    DateTime? lastStudied,
    int? mistakesCount,
    double? lastAccuracy,
    int? totalAttempts,
    Map<String, dynamic>? sentenceAccuracies,
    Map<String, dynamic>? additionalData,
  }) {
    return UserProgress(
      id: id ?? this.id,
      lectureId: lectureId ?? this.lectureId,
      progress: progress ?? this.progress,
      lastStudied: lastStudied ?? this.lastStudied,
      mistakesCount: mistakesCount ?? this.mistakesCount,
      lastAccuracy: lastAccuracy ?? this.lastAccuracy,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      sentenceAccuracies: sentenceAccuracies ?? this.sentenceAccuracies,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}