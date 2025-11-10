import 'package:flutter/material.dart';
import '../../domain/entities/employee.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final Employee employee;
  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(employee.name)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text('ID: ${employee.id}'),
              subtitle: Text('${employee.company} • ${employee.department}'),
            ),
          ),
          const SizedBox(height: 8),
          _Section(title: 'Historial de permisos', items: const [
            'Permiso médico - 12/08/2024',
            'Permiso personal - 25/07/2024',
          ]),
          _Section(title: 'Vacaciones', items: const [
            '2024-07-01 al 2024-07-15 (15 días)',
          ]),
          _Section(title: 'Permisos solicitados', items: const [
            'Pendiente: Ausencia 10/11/2024',
          ]),
          _Section(title: 'Tardanzas', items: const [
            '10/11/2024 - 15 minutos',
            '02/11/2024 - 5 minutos',
          ]),
          _Section(title: 'Salidas tempranas', items: const [
            '03/11/2024 - Emergencia familiar',
          ]),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<String> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text('Sin registros', style: TextStyle(color: Colors.black54))
            else
              ...items.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 8, color: Colors.black45),
                        const SizedBox(width: 8),
                        Expanded(child: Text(e)),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}