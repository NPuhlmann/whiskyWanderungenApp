/// ReviewRating-Model: Einzelne Bewertung einer Kategorie innerhalb eines Reviews
class ReviewRating {
  final int reviewId;
  final int categoryId;
  final double rating; // 1.0 bis 5.0
  final String? notes; // optional, max 500 Zeichen
  final DateTime createdAt;

  ReviewRating({
    required this.reviewId,
    required this.categoryId,
    required this.rating,
    this.notes,
    DateTime? createdAt,
  }) : assert(
         rating >= 1.0 && rating <= 5.0,
         'Rating must be between 1.0 and 5.0',
       ),
       assert(
         notes == null || notes.length <= 500,
         'Notes must be 500 characters or less',
       ),
       createdAt = createdAt ?? DateTime.now();

  ReviewRating copyWith({
    int? reviewId,
    int? categoryId,
    double? rating,
    String? notes,
    DateTime? createdAt,
  }) {
    return ReviewRating(
      reviewId: reviewId ?? this.reviewId,
      categoryId: categoryId ?? this.categoryId,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'category_id': categoryId,
      'rating': rating,
      if (notes != null) 'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ReviewRating.fromJson(Map<String, dynamic> json) {
    return ReviewRating(
      reviewId: json['review_id'] as int,
      categoryId: json['category_id'] as int,
      rating: (json['rating'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Berechnet den gewichteten Score auf Basis einer Kategorie-Gewichtung [weight]
  double calculateWeightedScore(double weight) {
    return rating * weight;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewRating &&
        other.reviewId == reviewId &&
        other.categoryId == categoryId &&
        other.rating == rating &&
        other.notes == notes;
  }

  @override
  int get hashCode => Object.hash(reviewId, categoryId, rating, notes);

  @override
  String toString() {
    return 'ReviewRating(reviewId: $reviewId, categoryId: $categoryId, rating: $rating, notes: $notes, createdAt: $createdAt)';
  }
}
