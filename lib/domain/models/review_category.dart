/// ReviewCategory-Model für verschiedene Bewertungskategorien
class ReviewCategory {
  final int id;
  final String name;
  final String description;
  final double weight;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.weight,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : assert(
          weight >= 0.0 && weight <= 1.0,
          'Weight must be between 0.0 and 1.0',
        ),
       assert(
          name.isNotEmpty && name.length <= 100,
          'Name must not be empty and must be 100 characters or less',
        ),
       assert(
          description.isNotEmpty,
          'Description must not be empty',
        ),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Erstellt eine Kopie der Kategorie mit geänderten Werten
  ReviewCategory copyWith({
    int? id,
    String? name,
    String? description,
    double? weight,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      weight: weight ?? this.weight,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Konvertiert die Kategorie zu JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'weight': weight,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Erstellt eine Kategorie aus JSON
  factory ReviewCategory.fromJson(Map<String, dynamic> json) {
    return ReviewCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      weight: (json['weight'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Berechnet den gewichteten Score für diese Kategorie
  double calculateWeightedScore(double score) {
    return score * weight;
  }

  /// Formatiertes Erstellungsdatum
  String get formattedCreatedAt {
    return '${createdAt.day}.${createdAt.month}.${createdAt.year}';
  }

  /// Formatiertes Aktualisierungsdatum
  String get formattedUpdatedAt {
    return '${updatedAt.day}.${updatedAt.month}.${updatedAt.year}';
  }

  /// Gewichtung als Prozentsatz
  String get weightPercentage {
    return '${(weight * 100).round()}%';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewCategory &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.weight == weight &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      weight,
      isActive,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'ReviewCategory(id: $id, name: $name, description: $description, weight: $weight, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
