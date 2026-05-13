class SellerModel {
  final int id;
  final String nickname;
  final String country;

  const SellerModel({
    required this.id,
    required this.nickname,
    required this.country,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) => SellerModel(
        id: json['id'] as int,
        nickname: json['nickname'] as String? ?? '',
        country: json['country'] as String? ?? '',
      );
}
