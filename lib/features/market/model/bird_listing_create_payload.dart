class BirdListingCreatePayload {
  final String name;
  final String ringNumber;
  final String gender;
  final String colour;
  final String price;
  final String description;
  final String? birthday;
  final String? achievements;

  const BirdListingCreatePayload({
    required this.name,
    required this.ringNumber,
    required this.gender,
    required this.colour,
    required this.price,
    required this.description,
    this.birthday,
    this.achievements,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'ring_number': ringNumber,
        'gender': gender,
        'colour': colour,
        'price': price,
        'description': description,
        'is_market_listed': true,
        if (birthday != null) 'birthday': birthday,
        if (achievements != null && achievements!.isNotEmpty)
          'achievements': achievements,
      };
}
