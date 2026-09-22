class Section {
  final String id;
  final String pieceId;
  String title;
  int sortOrder;
  final DateTime createdAt;
  int currentCount;
  int targetCount;

  Section({
    required this.id,
    required this.pieceId,
    required this.title,
    required this.sortOrder,
    required this.createdAt,
    required this.currentCount,
    required this.targetCount
  });
}