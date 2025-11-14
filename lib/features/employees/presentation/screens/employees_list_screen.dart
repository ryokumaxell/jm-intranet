import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_intranet/core/constants/app_text_styles.dart';
import 'package:j_intranet/core/constants/app_constants.dart';
import 'package:j_intranet/features/auth/presentation/providers/auth_providers.dart';
import 'package:j_intranet/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:j_intranet/features/requests/presentation/screens/requests_list_screen.dart';
import 'package:j_intranet/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:j_intranet/features/settings/presentation/screens/settings_screen.dart';
import '../../domain/entities/employee.dart';
import '../providers/employee_providers.dart';
import 'employee_detail_screen.dart';

class EmployeesListScreen extends ConsumerStatefulWidget {
  const EmployeesListScreen({super.key});

  @override
  ConsumerState<EmployeesListScreen> createState() =>
      _EmployeesListScreenState();
}

class _EmployeesListScreenState extends ConsumerState<EmployeesListScreen> {
  @override
  void initState() {
    super.initState();
    // La carga inicial de datos ahora se maneja en el build de EmployeesNotifier
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsyncValue = ref.watch(employeesProvider);
    final session = ref.watch(authSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleados'),
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
          Text(session?.user.email ?? 'Invitado', style: AppTextStyles.body),
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
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_outlined),
              title: const Text('Solicitudes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RequestsListScreen()),
                );
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
                  Text(
                    '${AppConstants.appName} v0.1.0',
                    style: AppTextStyles.small.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: employeesAsyncValue.when(
        data: (employees) {
          final jaysa =
              employees.where((e) => e.company == 'Jaysa Muebles').toList();
          final helaco = employees.where((e) => e.company == 'Helaco').toList();

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _CompanySection(title: 'Jaysa Muebles', employees: jaysa),
              const SizedBox(height: 12),
              _CompanySection(title: 'Helaco', employees: helaco),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _CompanySection extends StatelessWidget {
  final String title;
  final List<Employee> employees;

  const _CompanySection({
    required this.title,
    required this.employees,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (employees.isEmpty)
              const Text('Sin empleados',
                  style: TextStyle(color: Colors.black54))
            else
              ...employees.map((e) => ListTile(
                    leading:
                        const CircleAvatar(child: Icon(Icons.person_outline)),
                    title: Text(e.name),
                    subtitle: Text('${e.department} • ${e.id}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EmployeeDetailScreen(employee: e),
                        ),
                      );
                    },
                  )),
          ],
        ),
      ),
    );
  }
}
