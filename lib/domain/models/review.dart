
/// Review-Model für Whisky-Hike-Bewertungen
class Review {
  final int id;
  final int hikeId;
  final String userId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? userFirstName;
  final String? userLastName;

  Review({
    required this.id,
    required this.hikeId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.userFirstName,
    this.userLastName,
  }) : assert(
          rating >= 1.0 && rating <= 5.0,
          'Rating must be between 1.0 and 5.0',
        ),
       assert(
          comment.isNotEmpty && comment.length <= 1000,
          'Comment must not be empty and must be 1000 characters or less',
        );

  /// Erstellt eine Kopie des Reviews mit geänderten Werten
  Review copyWith({
    int? id,
    int? hikeId,
    String? userId,
    double? rating,
    String? comment,
    DateTime? createdAt,
    String? userFirstName,
    String? userLastName,
  }) {
    return Review(
      id: id ?? this.id,
      hikeId: hikeId ?? this.hikeId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      userFirstName: userFirstName ?? this.userFirstName,
      userLastName: userLastName ?? this.userLastName,
    );
  }

  /// Konvertiert das Review zu JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hike_id': hikeId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      if (userFirstName != null) 'user_first_name': userFirstName,
      if (userLastName != null) 'user_last_name': userLastName,
    };
  }

  /// Erstellt ein Review aus JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      hikeId: json['hike_id'] as int,
      userId: json['user_id'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userFirstName: json['user_first_name'] as String?,
      userLastName: json['user_last_name'] as String?,
    );
  }

  /// Vollständiger Name des Benutzers
  String? get fullName {
    if (userFirstName != null && userLastName != null) {
      return '$userFirstName $userLastName';
    } else if (userFirstName != null) {
      return userFirstName;
    } else if (userLastName != null) {
      return userLastName;
    }
    return null;
  }

  /// Formatiertes Erstellungsdatum
  String get formattedCreatedAt {
    return '${createdAt.day}.${createdAt.month}.${createdAt.year}';
  }

  /// Stern-Bewertung als String (z.B. "★★★★☆" für 4.0)
  String get starRating {
    final fullStars = rating.floor();
    final hasHalfStar = rating % 1 >= 0.5;
    
    final stars = '★' * fullStars;
    final halfStar = hasHalfStar ? '☆' : '';
    final emptyStars = '☆' * (5 - fullStars - (hasHalfStar ? 1 : 0));
    
    return stars + halfStar + emptyStars;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review &&
        other.id == id &&
        other.hikeId == hikeId &&
        other.userId == userId &&
        other.rating == rating &&
        other.comment == comment &&
        other.createdAt == createdAt &&
        other.userFirstName == userFirstName &&
        other.userLastName == userLastName;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      hikeId,
      userId,
      rating,
      comment,
      createdAt,
      userFirstName,
      userLastName,
    );
  }

  @override
  String toString() {
    return 'Review(id: $id, hikeId: $hikeId, userId: $userId, rating: $rating, comment: $comment, createdAt: $createdAt, userFirstName: $userFirstName, userLastName: $userLastName)';
  }
}
