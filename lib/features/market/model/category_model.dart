class CategoryModel {
  final String id; // matches backend asset endpoint key: supplies|accessories|feeds|supplements|birds
  final String name;
  final String emoji;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.emoji,
  });
}
