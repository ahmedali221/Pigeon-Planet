class BirdSummaryModel {
  final int id;
  final String name;
  final String ringNumber;
  final String gender;
  final String colour;
  final DateTime? birthday;

  const BirdSummaryModel({
    required this.id,
    required this.name,
    required this.ringNumber,
    required this.gender,
    required this.colour,
    this.birthday,
  });

  factory BirdSummaryModel.fromJson(Map<String, dynamic> json) =>
      BirdSummaryModel(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        ringNumber: json['ring_number'] as String? ?? '',
        gender: json['gender'] as String? ?? '',
        colour: json['colour'] as String? ?? '',
        birthday: json['birthday'] != null
            ? DateTime.tryParse(json['birthday'] as String)
            : null,
      );
}
