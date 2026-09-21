class Piece {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;

  Piece({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });
}