import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManualAddEmployee extends StatefulWidget {
  const ManualAddEmployee({super.key});

  @override
  State<ManualAddEmployee> createState() => _ManualAddEmployeeState();
}

class _ManualAddEmployeeState extends State<ManualAddEmployee> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  String? _selectedCompany;

  Future<void> _saveEmployee() async {
    if (_formKey.currentState!.validate()) {
      final firestore = FirebaseFirestore.instance;
      final name = _nameController.text.trim();
      final department = _departmentController.text.trim();
      final company = _selectedCompany!;

      String idFromName(String name) {
        final lower = name.toLowerCase().trim();
        final collapsed = lower.replaceAll(RegExp(r"\s+"), "_");
        return collapsed.replaceAll(RegExp(r"[^a-z0-9_]+"), "");
      }

      final id = idFromName(name);
      final companyId = company.toLowerCase().replaceAll(' ', '_');
      final ref = firestore.collection('companies').doc(companyId).collection('employees').doc(id);

      await ref.set({
        'name': name,
        'role': '',
        'department': department,
        'company': company,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Empleado "$name" guardado exitosamente.')),
        );
        _formKey.currentState!.reset();
        _nameController.clear();
        _departmentController.clear();
        setState(() {
          _selectedCompany = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Empleado',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, introduce un nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _departmentController,
              decoration: const InputDecoration(
                labelText: 'Departamento',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCompany,
              hint: const Text('Selecciona una empresa'),
              items: ['Jaysa Muebles', 'Helaco']
                  .map((company) => DropdownMenuItem(value: company, child: Text(company)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCompany = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Por favor, selecciona una empresa';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveEmployee,
              child: const Text('Guardar Empleado'),
            ),
          ],
        ),
      ),
    );
  }
}