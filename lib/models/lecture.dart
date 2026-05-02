class Lecture {
  final String id;
  final String subjectId;
  final int lectureNumber;
  final String lectureName;
  final String sourceContent;
  final List<String> contentIds; // References to Content ids
  final DateTime createdAt;

  const Lecture({
    required this.id,
    required this.subjectId,
    required this.lectureNumber,
    this.lectureName = '',
    this.sourceContent = '',
    required this.contentIds,
    required this.createdAt,
  });

  String get title => lectureName.isNotEmpty ? lectureName : 'Lecture $lectureNumber';

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      lectureNumber: json['lectureNumber'] as int? ?? 1,
      lectureName: json['lectureName'] as String? ?? json['title'] as String? ?? '',
      sourceContent: json['sourceContent'] as String? ?? '',
      contentIds: List<String>.from(json['contentIds'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'lectureNumber': lectureNumber,
      'lectureName': lectureName,
      'sourceContent': sourceContent,
      'contentIds': contentIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Lecture copyWith({
    String? id,
    String? subjectId,
    int? lectureNumber,
    String? lectureName,
    String? sourceContent,
    List<String>? contentIds,
    DateTime? createdAt,
  }) {
    return Lecture(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      lectureNumber: lectureNumber ?? this.lectureNumber,
      lectureName: lectureName ?? this.lectureName,
      sourceContent: sourceContent ?? this.sourceContent,
      contentIds: contentIds ?? this.contentIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}