import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BatchAddEmployees extends StatefulWidget {
  const BatchAddEmployees({super.key});

  @override
  State<BatchAddEmployees> createState() => _BatchAddEmployeesState();
}

class _BatchAddEmployeesState extends State<BatchAddEmployees> {
  final _controller = TextEditingController();
  int _lineCount = 0;
  String? _selectedCompany;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        final text = _controller.text;
        if (text.isEmpty) {
          _lineCount = 0;
        } else {
          _lineCount = '\n'.allMatches(text).length + 1;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Carga'),
        content: Text(
          _selectedCompany == null
              ? 'Selecciona una empresa antes de continuar.'
              : 'Se van a cargar $_lineCount empleados a "$_selectedCompany". ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () {
              if (_selectedCompany == null) {
                return;
              }
              Navigator.of(context).pop();
              _uploadEmployees();
            },
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadEmployees() async {
    final firestore = FirebaseFirestore.instance;
    final names = _controller.text.split('\n').where((name) => name.trim().isNotEmpty).toList();

    String idFromName(String name) {
      final lower = name.toLowerCase().trim();
      final collapsed = lower.replaceAll(RegExp(r"\s+"), "_");
      return collapsed.replaceAll(RegExp(r"[^a-z0-9_]+"), "");
    }

    final company = _selectedCompany!;
    final companyId = company.toLowerCase().replaceAll(' ', '_');

    // Asegura que el documento de la empresa exista
    await firestore.collection('companies').doc(companyId).set(
      {
        'name': company,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    final batch = firestore.batch();
    for (final n in names) {
      final id = idFromName(n);
      final ref = firestore.collection('companies').doc(companyId).collection('employees').doc(id);
      batch.set(ref, {
        'name': n,
        'role': '',
        'department': '',
        'company': company,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${names.length} empleados cargados exitosamente a "$company".')),
      );
      _controller.clear();
      setState(() {
        _selectedCompany = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedCompany,
            hint: const Text('Selecciona una empresa'),
            items: const [
              DropdownMenuItem(value: 'Jaysa Muebles', child: Text('Jaysa Muebles')),
              DropdownMenuItem(value: 'Helaco', child: Text('Helaco')),
            ],
            onChanged: (value) => setState(() => _selectedCompany = value),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pega la lista de nombres de los empleados, uno por línea. Se contarán las filas y se te pedirá confirmación antes de subirlos.',
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Pega los nombres aquí...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nombres detectados: $_lineCount'),
              ElevatedButton(
                onPressed: _lineCount > 0 && _selectedCompany != null ? _showConfirmationDialog : null,
                child: const Text('Cargar Empleados'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}