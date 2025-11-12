import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:j_intranet/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_intranet/firebase_options.dart';
import 'core/providers/theme_provider.dart';
import 'package:j_intranet/features/auth/presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await setAdminRole(); // This will run only once to set the admin role.
  runApp(const ProviderScope(child: JIntranetApp()));
}

Future<void> setAdminRole() async {
  final firestore = FirebaseFirestore.instance;
  final userRef = firestore.collection('users').doc('fHdphyxWx6frF26fVTUhPFI0yRF2');

  await userRef.set({
    'email': 'lacosta@jaysa.com',
    'role': 'admin',
    'createdAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true)); // Use merge to avoid overwriting existing data

  print('User role updated successfully!');
}

class JIntranetApp extends ConsumerWidget {
  const JIntranetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: AppConstants.appName,
      themeMode: mode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
