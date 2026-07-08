class Review {
  final String id;
  /// Raw rating on a 0–10 scale (as returned by API)
  final double ratingOutOf10;
  final String? type;
  final String? discription;
  final String? userId;
  final String? createdAt;

  Review({
    required this.id,
    required this.ratingOutOf10,
    this.type,
    this.discription,
    this.userId,
    this.createdAt,
  });

  /// Rating converted to 0–5 scale for star display
  double get ratingStars => (ratingOutOf10 / 2).clamp(0.0, 5.0);

  factory Review.fromJson(Map<String, dynamic> json) {
    // Safely parse rating: API returns it as a String (e.g. "10") or num
    double ratingOutOf10 = 0.0;
    final rawRating = json['rating'];
    if (rawRating != null) {
      if (rawRating is num) {
        ratingOutOf10 = rawRating.toDouble();
      } else {
        ratingOutOf10 = double.tryParse(rawRating.toString()) ?? 0.0;
      }
    }

    return Review(
      id: json['id']?.toString() ?? '',
      ratingOutOf10: ratingOutOf10,
      type: json['type']?.toString(),
      // API uses 'discription' (typo in backend)
      discription: json['discription']?.toString(),
      userId: json['user_id']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
