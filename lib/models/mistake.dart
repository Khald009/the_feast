class Mistake {
  final String id;
  final String lectureId;
  final String description;
  final String? correction; // Optional suggested correction
  final DateTime date;

  const Mistake({
    required this.id,
    required this.lectureId,
    required this.description,
    this.correction,
    required this.date,
  });

  factory Mistake.fromJson(Map<String, dynamic> json) {
    return Mistake(
      id: json['id'] as String,
      lectureId: json['lectureId'] as String,
      description: json['description'] as String,
      correction: json['correction'] as String?,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lectureId': lectureId,
      'description': description,
      'correction': correction,
      'date': date.toIso8601String(),
    };
  }

  Mistake copyWith({
    String? id,
    String? lectureId,
    String? description,
    String? correction,
    DateTime? date,
  }) {
    return Mistake(
      id: id ?? this.id,
      lectureId: lectureId ?? this.lectureId,
      description: description ?? this.description,
      correction: correction ?? this.correction,
      date: date ?? this.date,
    );
  }
}