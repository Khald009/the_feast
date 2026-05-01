enum ContentType { text, pdf }

class Content {
  final String id;
  final String lectureId;
  final ContentType type;
  final String data; // Text content or file path for PDF
  final Map<String, dynamic>? metadata; // Optional metadata like file size, etc.
  final DateTime createdAt;

  const Content({
    required this.id,
    required this.lectureId,
    required this.type,
    required this.data,
    this.metadata,
    required this.createdAt,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'] as String,
      lectureId: json['lectureId'] as String,
      type: ContentType.values[json['type'] as int],
      data: json['data'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lectureId': lectureId,
      'type': type.index,
      'data': data,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Content copyWith({
    String? id,
    String? lectureId,
    ContentType? type,
    String? data,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return Content(
      id: id ?? this.id,
      lectureId: lectureId ?? this.lectureId,
      type: type ?? this.type,
      data: data ?? this.data,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}