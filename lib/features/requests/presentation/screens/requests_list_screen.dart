import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_intranet/core/constants/app_text_styles.dart';
import 'package:j_intranet/core/constants/app_constants.dart';
import 'package:j_intranet/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:j_intranet/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:j_intranet/features/employees/presentation/screens/employees_list_screen.dart';
import 'package:j_intranet/features/settings/presentation/screens/settings_screen.dart';
import 'package:j_intranet/features/auth/presentation/providers/auth_providers.dart';

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
    // La carga inicial de datos ahora se maneja en el build de RequestsNotifier
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsyncValue = ref.watch(requestsProvider);
    final session = ref.watch(authSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Abrir menú',
          ),
        ),
        actions: [
          const Icon(Icons.notifications_none),
          const SizedBox(width: 8),
          Text(session?.user.name ?? 'Invitado', style: AppTextStyles.body),
          const SizedBox(width: 12),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture:
                  const CircleAvatar(child: Icon(Icons.person)),
              accountName: Text(session?.user.name ?? 'Invitado'),
              accountEmail: Text(session?.user.email ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Panel principal'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_alt_outlined),
              title: const Text('Empleados'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const EmployeesListScreen()),
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
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Ajustes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text('${AppConstants.appName} v0.1.0',
                      style:
                          AppTextStyles.small.copyWith(color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: requestsAsyncValue.when(
        data: (requests) {
          final permisosPendientes = requests
              .where((e) =>
                  e.type == RequestType.permission &&
                  e.status == RequestStatus.pending)
              .toList();
          final vacaciones =
              requests.where((e) => e.type == RequestType.vacation).toList();
          final tardanzas =
              requests.where((e) => e.type == RequestType.tardiness).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              int cols = 1;
              if (w >= 1200) {
                cols = 3;
              } else if (w >= 800) {
                cols = 2;
              }
              final sections = [
                _RequestsSection(
                    title: 'Permisos pendientes', items: permisosPendientes),
                _RequestsSection(title: 'Vacaciones', items: vacaciones),
                _TardinessSection(items: tardanzas),
              ];
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: sections.length,
                  itemBuilder: (context, index) => sections[index],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Ejemplo: agregar una solicitud de vacaciones
          final session = ref.read(authSessionProvider);
          if (session != null) {
            await ref.read(requestsProvider.notifier).add(
                  type: 'vacation',
                  employeeId: session.user.id,
                  employeeName: session.user.email,
                  employeeEmail: session.user.email,
                  startDate: DateTime.now(),
                  reason: 'Demo request',
                );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar demo'),
      ),
    );
  }
}

class _RequestsSection extends StatelessWidget {
  final String title;
  final List<Request> items;
  const _RequestsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (items.isEmpty)
                const Text('Sin elementos',
                    style: TextStyle(color: Colors.black54))
              else
                ...items.map((req) => ListTile(
                      dense: true,
                      title: Text('${req.type} • ${req.status}'),
                      subtitle: Text('ID: ${req.id}'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => RequestDetailScreen(id: req.id)),
                        );
                      },
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

class _TardinessSection extends StatelessWidget {
  final List<Request> items;
  const _TardinessSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Internas (Tardanzas)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (items.isEmpty)
                const Text('Sin notificaciones de tardanza',
                    style: TextStyle(color: Colors.black54))
              else
                ...items.map((req) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tardanza • ${req.status}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('ID: ${req.id}',
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 12)),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (_) => const TardinessModal());
                                },
                                icon: const Icon(Icons.timelapse),
                                label: const Text('Registrar tardanza'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
            ],
          ),
        ),
      ),
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
                  const Text('Registrar tardanza',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Empleado'),
                    onChanged: (v) => employee = v,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
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
                            final picked = await showTimePicker(
                                context: context, initialTime: time);
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
                          decoration: const InputDecoration(
                              labelText: 'Minutos de tardanza'),
                          initialValue: minutesLate.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (v) =>
                              minutesLate = int.tryParse(v) ?? minutesLate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Motivo'),
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
                            if (formKey.currentState?.validate() != true) {
                              return;
                            }
                            Navigator.of(context).pop();
                            final hh = time.hour.toString().padLeft(2, '0');
                            final mm = time.minute.toString().padLeft(2, '0');
                            final msg =
                                'Tardanza registrada: ${employee ?? ''}, ${date.year}-${date.month}-${date.day} $hh:$mm, ${minutesLate}m, motivo: ${reason ?? '-'}';
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(msg)));
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
