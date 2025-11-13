import 'package:firebase_auth/firebase_auth.dart';
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
  await setupAdminUser(); // Configurar usuario admin de forma segura
  runApp(const ProviderScope(child: JIntranetApp()));
}

Future<void> setupAdminUser() async {
  try {
    final auth = FirebaseAuth.instance;
    
    // Intentar autenticar con el usuario admin primero
    UserCredential? userCredential;
    try {
      userCredential = await auth.signInWithEmailAndPassword(
        email: 'lacosta@jaysa.com',
        password: 'Admin123!',
      );
    } catch (e) {
      // Si no existe, crear el usuario
      try {
        userCredential = await auth.createUserWithEmailAndPassword(
          email: 'lacosta@jaysa.com',
          password: 'Admin123!',
        );
      } catch (createError) {
        print('Error al crear usuario admin: $createError');
        return;
      }
    }

    if (userCredential?.user != null) {
      final uid = userCredential!.user!.uid;
      final firestore = FirebaseFirestore.instance;
      final userRef = firestore.collection('users').doc(uid);

      await userRef.set({
        'email': 'lacosta@jaysa.com',
        'role': 'admin',
        'name': 'Administrador Principal',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('Usuario admin configurado exitosamente con UID: $uid');
      
      // Cerrar sesión para que el usuario pueda loguearse normalmente
      await auth.signOut();
    }
  } catch (e) {
    print('Error configurando admin: $e');
  }
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
