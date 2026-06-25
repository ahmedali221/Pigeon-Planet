class ClockAgentModel {
  final String id;
  final String name;
  final String governorate;
  final String? photoUrl;
  final String phoneNumber;

  const ClockAgentModel({
    required this.id,
    required this.name,
    required this.governorate,
    this.photoUrl,
    required this.phoneNumber,
  });
}

class ElectronicClockModel {
  final String id;
  final String name;
  final String brand;
  final String description;
  final double price;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final List<String> features;
  final ClockAgentModel agent;

  const ElectronicClockModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.inStock,
    required this.features,
    required this.agent,
  });
}
