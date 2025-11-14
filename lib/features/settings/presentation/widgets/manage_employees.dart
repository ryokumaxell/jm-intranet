import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageEmployees extends StatefulWidget {
  const ManageEmployees({super.key});

  @override
  State<ManageEmployees> createState() => _ManageEmployeesState();
}

class _ManageEmployeesState extends State<ManageEmployees> {
  String? _selectedCompany;
  final TextEditingController _searchController = TextEditingController();

  String _companyId(String company) {
    final lower = company.toLowerCase().trim();
    return lower.replaceAll(RegExp(r"\s+"), "_");
  }

  Future<void> _editEmployee(DocumentReference<Map<String, dynamic>> ref, String currentName, String currentDept) async {
    final nameCtrl = TextEditingController(text: currentName);
    final deptCtrl = TextEditingController(text: currentDept);
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar empleado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deptCtrl,
                decoration: const InputDecoration(labelText: 'Departamento'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () => Navigator.pop(context, {
                  'name': nameCtrl.text.trim(),
                  'department': deptCtrl.text.trim(),
                }), child: const Text('Guardar')),
          ],
        );
      },
    );
    if (result != null) {
      await ref.update({'name': result['name'] ?? currentName, 'department': result['department'] ?? currentDept, 'updatedAt': FieldValue.serverTimestamp()});
    }
  }

  Future<void> _deleteEmployee(DocumentReference<Map<String, dynamic>> ref, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar empleado'),
          content: Text('¿Eliminar "$name"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
          ],
        );
      },
    );
    if (confirm == true) {
      await ref.delete();
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
            onChanged: (v) {
              setState(() {
                _selectedCompany = v;
              });
            },
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Buscar',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedCompany == null
                ? const Center(child: Text('Selecciona una empresa'))
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('companies')
                        .doc(_companyId(_selectedCompany!))
                        .collection('employees')
                        .orderBy('name')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final docs = snapshot.data?.docs ?? [];
                      final q = _searchController.text.trim().toLowerCase();
                      final filtered = q.isEmpty
                          ? docs
                          : docs.where((d) {
                              final data = d.data();
                              final name = (data['name'] ?? '').toString().toLowerCase();
                              final dept = (data['department'] ?? '').toString().toLowerCase();
                              return name.contains(q) || dept.contains(q);
                            }).toList();
                      if (filtered.isEmpty) {
                        return const Center(child: Text('Sin empleados'));
                      }
                      return ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final d = filtered[index];
                          final data = d.data();
                          final name = (data['name'] ?? '').toString();
                          final department = (data['department'] ?? '').toString();
                          final ref = d.reference;
                          return ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: Text(name),
                            subtitle: Text(department.isEmpty ? 'Sin departamento' : department),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: 'Editar',
                                  onPressed: () => _editEmployee(ref, name, department),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Eliminar',
                                  onPressed: () => _deleteEmployee(ref, name),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}