import 'package:j_intranet/features/settings/presentation/screens/employee_edit_screen.dart';
import 'package:j_intranet/features/settings/presentation/screens/profile_management_screen.dart';
import 'package:j_intranet/features/settings/presentation/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.manage_accounts_outlined),
            title: const Text('Gestión de empleados'),
            subtitle: const Text('Editar nombre, compañía y departamento'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EmployeeEditScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings_outlined),
            title: const Text('Gestión de perfiles'),
            subtitle:
                const Text('Crear usuarios, roles y accesos por compañía'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProfileManagementScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Perfil'),
            subtitle: const Text('Gestiona la información de tu perfil'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const UserProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
