class Section {
  final String id;
  final String pieceId;
  String title;
  int sortOrder;
  final DateTime createdAt;

  Section({
    required this.id,
    required this.pieceId,
    required this.title,
    required this.sortOrder,
    required this.createdAt,
  });
}