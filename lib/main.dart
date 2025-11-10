import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_intranet/core/constants/app_constants.dart';
import 'package:j_intranet/features/auth/presentation/screens/login_screen.dart';

void main() {
  runApp(const ProviderScope(child: JIntranetApp()));
}

class JIntranetApp extends StatelessWidget {
  const JIntranetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
