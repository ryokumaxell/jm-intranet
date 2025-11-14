import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  State<ProfileManagementScreen> createState() =>
      _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Create form controllers
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  String _role = 'admin'; // super | admin | user
  bool _canSeeJaysa = true;
  bool _canSeeHelaco = true;
  bool _creating = false;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    final email = _emailCtl.text.trim();
    final password = _passwordCtl.text;
    if (email.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Ingresa email y contraseña (mín. 6 caracteres)')),
      );
      return;
    }
    final companies = <String>[
      if (_canSeeJaysa) 'Jaysa Muebles',
      if (_canSeeHelaco) 'Helaco',
    ];
    if (companies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una compañía')),
      );
      return;
    }

    setState(() => _creating = true);
    try {
      // Create user in Firebase Auth
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final uid = cred.user!.uid;
      // Persist profile in Firestore
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'role': _role, // admin | viewer
        'companies': companies, // ['Jaysa Muebles', 'Helaco']
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) {
        _emailCtl.clear();
        _passwordCtl.clear();
        _role = 'user';
        _canSeeJaysa = true;
        _canSeeHelaco = false;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario creado exitosamente')),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error creando usuario')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<List<_UserRow>> _loadUsers() async {
    try {
      final snap = await _firestore.collection('users').orderBy('email').get();
      return snap.docs.map((d) {
        final data = d.data();
        final companies =
            (data['companies'] as List?)?.map((e) => e.toString()).toList() ??
                const <String>[];
        return _UserRow(
          uid: d.id,
          email: (data['email'] ?? '').toString(),
          role: (data['role'] ?? 'viewer').toString(),
          companies: companies,
        );
      }).toList();
    } catch (_) {
      final snap = await _firestore.collection('users').get();
      return snap.docs.map((d) {
        final data = d.data();
        final companies =
            (data['companies'] as List?)?.map((e) => e.toString()).toList() ??
                const <String>[];
        return _UserRow(
          uid: d.id,
          email: (data['email'] ?? '').toString(),
          role: (data['role'] ?? 'viewer').toString(),
          companies: companies,
        );
      }).toList();
    }
  }

  Future<void> _editUser(_UserRow u) async {
    String role = u.role;
    bool seeJaysa = u.companies.contains('Jaysa Muebles');
    bool seeHelaco = u.companies.contains('Helaco');

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
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Editar usuario: ${u.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    items: const [
                      DropdownMenuItem(
                          value: 'super', child: Text('Súper administrador')),
                      DropdownMenuItem(
                          value: 'admin', child: Text('Administrador')),
                      DropdownMenuItem(value: 'user', child: Text('Usuario')),
                    ],
                    onChanged: (v) => role = v ?? role,
                    decoration: const InputDecoration(labelText: 'Rol'),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: seeJaysa,
                    onChanged: (v) => setState(() => seeJaysa = v ?? false),
                    title: const Text('Acceso a Jaysa Muebles'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: seeHelaco,
                    onChanged: (v) => setState(() => seeHelaco = v ?? false),
                    title: const Text('Acceso a Helaco'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancelar')),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          final companies = <String>[
                            if (seeJaysa) 'Jaysa Muebles',
                            if (seeHelaco) 'Helaco',
                          ];
                          if (companies.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Selecciona al menos una compañía')),
                            );
                            return;
                          }
                          await _firestore.collection('users').doc(u.uid).set({
                            'role': role,
                            'companies': companies,
                            'updatedAt': FieldValue.serverTimestamp(),
                          }, SetOptions(merge: true));
                          if (mounted) {
                            Navigator.pop(ctx);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Usuario actualizado')),
                            );
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestión de Perfiles'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'CREAR'),
              Tab(text: 'USUARIOS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Crear usuario
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('Crear nuevo usuario',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailCtl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordCtl,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Contraseña (mín. 6 caracteres)'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _role,
                      items: const [
                        DropdownMenuItem(
                            value: 'super', child: Text('Súper administrador')),
                        DropdownMenuItem(
                            value: 'admin', child: Text('Administrador')),
                        DropdownMenuItem(value: 'user', child: Text('Usuario')),
                      ],
                      onChanged: (v) => setState(() => _role = v ?? 'user'),
                      decoration: const InputDecoration(labelText: 'Rol'),
                    ),
                    const SizedBox(height: 12),
                    const Text('Acceso a compañías:'),
                    CheckboxListTile(
                      value: _canSeeJaysa,
                      onChanged: (v) =>
                          setState(() => _canSeeJaysa = v ?? false),
                      title: const Text('Jaysa Muebles'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      value: _canSeeHelaco,
                      onChanged: (v) =>
                          setState(() => _canSeeHelaco = v ?? false),
                      title: const Text('Helaco'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _creating ? null : _createUser,
                      icon: _creating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text('Crear usuario'),
                    ),
                  ],
                ),
              ),
            ),
            // Usuarios existentes
            FutureBuilder<List<_UserRow>>(
              future: _loadUsers(),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Error cargando usuarios: ${snap.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final items = snap.data ?? const [];
                if (items.isEmpty) {
                  return const Center(child: Text('No hay usuarios'));
                }
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final u = items[i];
                        final companies = u.companies.join(' • ');
                        return ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(u.email),
                          subtitle: Text('${u.role} • $companies'),
                          trailing: IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.manage_accounts_outlined),
                            onPressed: () => _editUser(u),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _UserRow {
  final String uid;
  final String email;
  final String role;
  final List<String> companies;

  _UserRow({
    required this.uid,
    required this.email,
    required this.role,
    required this.companies,
  });
}
