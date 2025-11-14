import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:j_intranet/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_intranet/firebase_options.dart';
import 'core/providers/theme_provider.dart';
import 'package:j_intranet/features/auth/presentation/screens/login_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:j_intranet/features/requests/presentation/screens/permissions_pin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: JIntranetApp()));
}

class JIntranetApp extends ConsumerWidget {
  const JIntranetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: 'jaysamuebleintranet.web.app/formulario',
          builder: (context, state) => const PermissionsFormScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: AppConstants.appName,
      themeMode: mode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo, brightness: Brightness.dark),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
