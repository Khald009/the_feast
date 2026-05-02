class Subject {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String>? lectureIds;

  const Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    this.lectureIds,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      lectureIds: json['lectureIds'] != null ? List<String>.from(json['lectureIds']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lectureIds': lectureIds,
    };
  }

  Subject copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? lectureIds,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lectureIds: lectureIds ?? this.lectureIds,
    );
  }

  // Computed property for lectures count
  int get lecturesCount => lectureIds?.length ?? 0;
}