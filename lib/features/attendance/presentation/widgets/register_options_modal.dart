import 'package:flutter/material.dart';
import 'manual_entry_modal.dart';

class RegisterOptionsModal extends StatelessWidget {
  const RegisterOptionsModal({super.key, required this.employeeName, required this.date});

  final String employeeName;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth < 380 ? screenWidth * 0.9 : 340.0;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 280, maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Acciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('Empleado: $employeeName', style: const TextStyle(color: Colors.black54, fontSize: 12)),
              Text('Fecha: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
              const SizedBox(height: 12),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit, size: 20),
                title: const Text('Registrar asistencia', style: TextStyle(fontSize: 14)),
                onTap: () {
                  Navigator.of(context).pop();
                  showDialog(context: context, builder: (_) => const ManualEntryModal());
                },
              ),
              const Divider(height: 1),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_available, size: 20),
                title: const Text('Permiso', style: TextStyle(fontSize: 14)),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permiso: funcionalidad próximamente')));
                },
              ),
              const Divider(height: 1),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.timelapse, size: 20),
                title: const Text('Tardanza', style: TextStyle(fontSize: 14)),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tardanza: funcionalidad próximamente')));
                },
              ),
              const Divider(height: 1),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.report_problem, size: 20),
                title: const Text('Eventualidad', style: TextStyle(fontSize: 14)),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eventualidad: funcionalidad próximamente')));
                },
              ),
              const SizedBox(height: 6),
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
      ),
    );
  }
}