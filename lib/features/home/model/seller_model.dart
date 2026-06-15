class SellerModel {
  final int id;
  final String username;
  final String nickname;
  final String country;
  final double avgRating;
  final int ratingsCount;
  final int activeAuctionsCount;
  final int totalBirdsCount;

  const SellerModel({
    required this.id,
    required this.username,
    required this.nickname,
    required this.country,
    this.avgRating = 0.0,
    this.ratingsCount = 0,
    this.activeAuctionsCount = 0,
    this.totalBirdsCount = 0,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) => SellerModel(
        id: json['id'] as int,
        username: json['username'] as String? ?? '',
        nickname: json['nickname'] as String? ?? '',
        country: json['country'] as String? ?? '',
        avgRating: json['avg_rating'] != null
            ? double.tryParse(json['avg_rating'].toString()) ?? 0.0
            : 0.0,
        ratingsCount: json['ratings_count'] as int? ?? 0,
        activeAuctionsCount: json['active_auctions_count'] as int? ?? 0,
        totalBirdsCount: json['total_birds_count'] as int? ?? 0,
      );
}
