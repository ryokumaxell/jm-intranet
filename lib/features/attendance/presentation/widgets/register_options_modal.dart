import 'package:flutter/material.dart';
import 'manual_entry_modal.dart';

class RegisterOptionsModal extends StatelessWidget {
  const RegisterOptionsModal({super.key, required this.employeeId, required this.date});

  final String employeeId;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Acciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Empleado: $employeeId', style: const TextStyle(color: Colors.black54, fontSize: 12)),
            Text('Fecha: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Registrar asistencia'),
              onTap: () {
                Navigator.of(context).pop();
                showDialog(context: context, builder: (_) => const ManualEntryModal());
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.event_available),
              title: const Text('Permiso'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permiso: funcionalidad próximamente')));
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.timelapse),
              title: const Text('Tardanza'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tardanza: funcionalidad próximamente')));
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.report_problem),
              title: const Text('Eventualidad'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eventualidad: funcionalidad próximamente')));
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}