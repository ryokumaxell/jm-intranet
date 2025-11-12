import 'package:j_intranet/features/users/presentation/screens/create_user_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_intranet/features/auth/presentation/providers/auth_providers.dart';
import 'package:j_intranet/features/employees/presentation/screens/register_employee_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final isAdmin = session?.user.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        children: [
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Crear Usuario'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateUserScreen()),
                );
              },
            ),
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Registrar Empleado de Jaysa Muebles'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RegisterEmployeeScreen(company: 'Jaysa Muebles'),
                  ),
                );
              },
            ),
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Registrar Empleado de Helaco'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RegisterEmployeeScreen(company: 'Helaco'),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}