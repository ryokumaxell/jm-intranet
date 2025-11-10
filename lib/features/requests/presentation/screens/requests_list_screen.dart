import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_intranet/core/constants/app_text_styles.dart';
import 'package:j_intranet/core/constants/app_constants.dart';
import 'package:j_intranet/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:j_intranet/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:j_intranet/features/profile/presentation/screens/profile_screen.dart';

import '../providers/request_providers.dart';
import 'request_detail_screen.dart';
import '../../domain/entities/request.dart';

class RequestsListScreen extends ConsumerStatefulWidget {
  const RequestsListScreen({super.key});

  @override
  ConsumerState<RequestsListScreen> createState() => _RequestsListScreenState();
}

class _RequestsListScreenState extends ConsumerState<RequestsListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar datos iniciales
    Future.microtask(() => ref.read(requestsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(requestsProvider);
    final permisosPendientes = requests.where((e) => e.type == 'permission' && e.status == 'pending').toList();
    final vacaciones = requests.where((e) => e.type == 'vacation').toList();
    final tardanzas = requests.where((e) => e.type == 'tardiness').toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Solicitudes'),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Abrir menú',
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Permisos'),
              Tab(text: 'Vacaciones'),
              Tab(text: 'Internas (Tardanzas)'),
            ],
          ),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              const UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
                accountName: Text('Usuario'),
                accountEmail: Text('usuario@jaymuebles.com'),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard_outlined),
                title: const Text('Inicio'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt_outlined),
                title: const Text('Solicitudes'),
                selected: true,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.event_available_outlined),
                title: const Text('Asistencia'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Perfil'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Ajustes'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Spacer(),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text('${AppConstants.appName} v0.1.0', style: AppTextStyles.small.copyWith(color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _RequestsListView(items: permisosPendientes),
            _RequestsListView(items: vacaciones),
            _TardinessListView(items: tardanzas),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            // Ejemplo: agregar una solicitud de vacaciones
            await ref.read(requestsProvider.notifier).add('vacation');
          },
          icon: const Icon(Icons.add),
          label: const Text('Agregar demo'),
        ),
      ),
    );
  }
}

class _RequestsListView extends StatelessWidget {
  final List<Request> items;
  const _RequestsListView({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Sin elementos'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final req = items[index];
        return ListTile(
          title: Text('${req.type} • ${req.status}'),
          subtitle: Text('ID: ${req.id}'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RequestDetailScreen(id: req.id),
              ),
            );
          },
        );
      },
    );
  }
}

class _TardinessListView extends StatelessWidget {
  final List<Request> items;
  const _TardinessListView({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Sin notificaciones de tardanza'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final req = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tardanza • ${req.status}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('ID: ${req.id}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(context: context, builder: (_) => const TardinessModal());
                    },
                    icon: const Icon(Icons.timelapse),
                    label: const Text('Registrar tardanza'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TardinessModal extends StatelessWidget {
  const TardinessModal({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String? employee;
    DateTime date = DateTime.now();
    TimeOfDay time = TimeOfDay.now();
    int minutesLate = 10;
    String? reason;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Registrar tardanza', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Empleado'),
                    onChanged: (v) => employee = v,
                    validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text('${date.year}-${date.month}-${date.day}'),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: date,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setState(() => date = picked);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text(time.format(context)),
                          onPressed: () async {
                            final picked = await showTimePicker(context: context, initialTime: time);
                            if (picked != null) setState(() => time = picked);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Minutos de tardanza'),
                          initialValue: minutesLate.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => minutesLate = int.tryParse(v) ?? minutesLate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Motivo'),
                          onChanged: (v) => reason = v,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState?.validate() != true) return;
                            Navigator.of(context).pop();
                            final hh = time.hour.toString().padLeft(2, '0');
                            final mm = time.minute.toString().padLeft(2, '0');
                            final msg = 'Tardanza registrada: ${employee ?? ''}, ${date.year}-${date.month}-${date.day} $hh:$mm, ${minutesLate}m, motivo: ${reason ?? '-'}';
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                          },
                          child: const Text('Guardar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}