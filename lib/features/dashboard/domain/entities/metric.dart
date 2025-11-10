class Metric {
  final String key;
  final String title;
  final String value;
  final String? subtitle;

  const Metric({
    required this.key,
    required this.title,
    required this.value,
    this.subtitle,
  });
}