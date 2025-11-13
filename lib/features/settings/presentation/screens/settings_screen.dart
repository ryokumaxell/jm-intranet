import 'package:j_intranet/features/settings/presentation/screens/employee_management_screen.dart';
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
            leading: const Icon(Icons.person_add_alt_1_outlined),
            title: const Text('Empleados'),
            subtitle: const Text('Añadir, editar o eliminar empleados'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EmployeeManagementScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Perfil'),
            subtitle: const Text('Gestiona la información de tu perfil'),
            onTap: () {
              // TODO: Navegar a la pantalla de perfil
            },
          ),
        ],
      ),
    );
  }
}