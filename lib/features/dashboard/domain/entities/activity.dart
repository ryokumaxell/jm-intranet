class Activity {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String type;

  const Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });
}