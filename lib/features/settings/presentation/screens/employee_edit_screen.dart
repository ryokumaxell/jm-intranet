import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:j_intranet/features/settings/presentation/widgets/manual_add_employee.dart';
import 'package:j_intranet/features/settings/presentation/widgets/batch_add_employees.dart';

class EmployeeEditScreen extends StatefulWidget {
  const EmployeeEditScreen({super.key});

  @override
  State<EmployeeEditScreen> createState() => _EmployeeEditScreenState();
}

class _EmployeeEditScreenState extends State<EmployeeEditScreen> {
  final _firestore = FirebaseFirestore.instance;
  final List<String> _companies = const ['Jaysa Muebles', 'Helaco'];

  Future<List<_EmployeeDoc>> _loadEmployees() async {
    final companyIds = ['jaysa_muebles', 'helaco'];
    final snaps = await Future.wait(
      companyIds.map((c) => _firestore
          .collection('companies')
          .doc(c)
          .collection('employees')
          .get()),
    );
    final docs = snaps.expand((s) => s.docs);
    return docs.map((d) {
      final data = d.data();
      return _EmployeeDoc(
        id: d.id,
        name: (data['name'] ?? '').toString(),
        department: (data['department'] ?? '').toString(),
        company: (data['company'] ?? '').toString(),
        companyId: d.reference.parent.parent!.id, // jaysa_muebles | helaco
      );
    }).toList();
  }

  Future<void> _editEmployee(_EmployeeDoc emp) async {
    final nameCtl = TextEditingController(text: emp.name);
    final deptCtl = TextEditingController(text: emp.department);
    String company = emp.company;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Editar empleado',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameCtl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: deptCtl,
                    decoration:
                        const InputDecoration(labelText: 'Departamento'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: company.isNotEmpty ? company : null,
                    items: _companies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    decoration: const InputDecoration(labelText: 'Compañía'),
                    onChanged: (v) => company = v ?? emp.company,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          final newName = nameCtl.text.trim();
                          final newDept = deptCtl.text.trim();
                          final newCompany = company.trim();
                          if (newName.isEmpty ||
                              newDept.isEmpty ||
                              newCompany.isEmpty) return;

                          try {
                            // If company changes, move the doc to the other collection
                            final newCompanyId =
                                newCompany.toLowerCase().replaceAll(' ', '_');
                            final oldRef = _firestore
                                .collection('companies')
                                .doc(emp.companyId)
                                .collection('employees')
                                .doc(emp.id);
                            final newRef = _firestore
                                .collection('companies')
                                .doc(newCompanyId)
                                .collection('employees')
                                .doc(emp.id);

                            final data = {
                              'name': newName,
                              'department': newDept,
                              'company': newCompany,
                              'updatedAt': FieldValue.serverTimestamp(),
                            };

                            if (emp.companyId != newCompanyId) {
                              // Copy then delete to move across companies
                              await newRef.set(data, SetOptions(merge: true));
                              await oldRef.delete();
                            } else {
                              await oldRef.set(data, SetOptions(merge: true));
                            }

                            if (mounted) {
                              Navigator.pop(ctx);
                              setState(() {}); // refresh list
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Empleado actualizado')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error al actualizar: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteEmployee(_EmployeeDoc emp) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar empleado'),
        content: Text(
            '¿Seguro que deseas eliminar a "${emp.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final ref = _firestore
          .collection('companies')
          .doc(emp.companyId)
          .collection('employees')
          .doc(emp.id);
      await ref.delete();
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Empleado eliminado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestión de Empleados'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'EDITAR'),
              Tab(text: 'MANUAL'),
              Tab(text: 'POR LOTE'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FutureBuilder<List<_EmployeeDoc>>(
              future: _loadEmployees(),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snap.data ?? const [];
                if (items.isEmpty) {
                  return const Center(child: Text('No hay empleados'));
                }
                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final e = items[i];
                          return ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: Text(e.name),
                            subtitle: Text('${e.company} • ${e.department}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Editar',
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _editEmployee(e),
                                ),
                                IconButton(
                                  tooltip: 'Eliminar',
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.redAccent),
                                  onPressed: () => _deleteEmployee(e),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const ManualAddEmployee(),
            const BatchAddEmployees(),
          ],
        ),
      ),
    );
  }
}

class _EmployeeDoc {
  final String id;
  final String name;
  final String department;
  final String company; // display name
  final String companyId; // jaysa_muebles | helaco

  _EmployeeDoc({
    required this.id,
    required this.name,
    required this.department,
    required this.company,
    required this.companyId,
  });
}
