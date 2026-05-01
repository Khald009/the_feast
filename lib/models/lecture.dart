class Lecture {
  final String id;
  final String subjectId;
  final String title;
  final List<String> contentIds; // References to Content ids
  final DateTime createdAt;

  const Lecture({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.contentIds,
    required this.createdAt,
  });

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      title: json['title'] as String,
      contentIds: List<String>.from(json['contentIds'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'title': title,
      'contentIds': contentIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Lecture copyWith({
    String? id,
    String? subjectId,
    String? title,
    List<String>? contentIds,
    DateTime? createdAt,
  }) {
    return Lecture(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      contentIds: contentIds ?? this.contentIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}