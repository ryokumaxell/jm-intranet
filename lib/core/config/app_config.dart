import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfig {
  final String baseUrl;
  const AppConfig({required this.baseUrl});
}

final appConfigProvider = Provider<AppConfig>(
  (ref) => const AppConfig(baseUrl: 'https://api.example.com'),
);