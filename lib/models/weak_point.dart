class WeakPoint {
  final String id;
  final String lectureId;
  final String sentence;
  final String word;
  final String character;
  final int mistakeCount;
  final DateTime lastReviewed;

  const WeakPoint({
    required this.id,
    required this.lectureId,
    required this.sentence,
    required this.word,
    required this.character,
    required this.mistakeCount,
    required this.lastReviewed,
  });

  factory WeakPoint.fromJson(Map<String, dynamic> json) {
    return WeakPoint(
      id: json['id'] as String,
      lectureId: json['lectureId'] as String,
      sentence: json['sentence'] as String,
      word: json['word'] as String,
      character: json['character'] as String,
      mistakeCount: json['mistakeCount'] as int,
      lastReviewed: DateTime.parse(json['lastReviewed'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lectureId': lectureId,
      'sentence': sentence,
      'word': word,
      'character': character,
      'mistakeCount': mistakeCount,
      'lastReviewed': lastReviewed.toIso8601String(),
    };
  }

  WeakPoint copyWith({
    String? id,
    String? lectureId,
    String? sentence,
    String? word,
    String? character,
    int? mistakeCount,
    DateTime? lastReviewed,
  }) {
    return WeakPoint(
      id: id ?? this.id,
      lectureId: lectureId ?? this.lectureId,
      sentence: sentence ?? this.sentence,
      word: word ?? this.word,
      character: character ?? this.character,
      mistakeCount: mistakeCount ?? this.mistakeCount,
      lastReviewed: lastReviewed ?? this.lastReviewed,
    );
  }
}
