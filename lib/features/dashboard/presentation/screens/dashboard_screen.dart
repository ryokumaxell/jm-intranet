import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_intranet/core/constants/app_colors.dart';
import 'package:j_intranet/core/constants/app_text_styles.dart';
import 'package:j_intranet/core/constants/app_constants.dart';
import 'package:j_intranet/features/auth/presentation/providers/auth_providers.dart';
import 'package:j_intranet/features/requests/presentation/screens/requests_list_screen.dart';
import 'package:j_intranet/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:j_intranet/features/profile/presentation/screens/profile_screen.dart';
import 'package:j_intranet/features/employees/presentation/screens/employees_list_screen.dart';
import 'package:j_intranet/core/providers/theme_provider.dart';
import 'package:j_intranet/features/employees/presentation/providers/employee_providers.dart';
import 'package:j_intranet/features/requests/presentation/providers/request_providers.dart';
import 'package:j_intranet/features/attendance/presentation/providers/attendance_providers.dart';
import 'package:j_intranet/features/attendance/domain/entities/attendance_record.dart';
import 'package:j_intranet/features/dashboard/domain/entities/metric.dart';

import '../providers/dashboard_providers.dart';
import '../widgets/summary_card.dart';
import '../widgets/chart_placeholder.dart';
import '../widgets/activity_list.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedDrawerIndex = 0;

  @override
  void initState() {
    super.initState();
    // Asegurar datos para métricas
    Future.microtask(() {
      ref.read(employeesProvider.notifier).load();
      ref.read(requestsProvider.notifier).load();
    });
  }

  int _columnsForWidth(double w) {
    if (w < 600) return 1; // móviles
    if (w < 1024) return 2; // tablets
    if (w < 1440) return 3; // escritorio mediano
    return 4; // escritorio ancho
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _buildMetrics(context);
    final activities = ref.watch(recentActivitiesProvider);
    final session = ref.watch(authSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Abrir menú',
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.business, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('Panel Principal', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          const Icon(Icons.notifications_none),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Modo oscuro',
            icon: const Icon(Icons.dark_mode_outlined),
            onPressed: () {
              final current = ref.read(themeModeProvider);
              ref.read(themeModeProvider.notifier).state =
                  current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          const SizedBox(width: 8),
          Text(session?.user.name ?? 'Invitado', style: AppTextStyles.body),
          const SizedBox(width: 12),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
              accountName: Text(session?.user.name ?? 'Invitado'),
              accountEmail: Text(session?.user.email ?? ''),
            ),
            _DrawerItem(
              icon: Icons.dashboard_outlined,
              title: 'Inicio',
              selected: _selectedDrawerIndex == 0,
              onTap: () {
                setState(() => _selectedDrawerIndex = 0);
                Navigator.pop(context);
              },
            ),
            _DrawerItem(
              icon: Icons.people_alt_outlined,
              title: 'Empleados',
              selected: _selectedDrawerIndex == 5,
              onTap: () {
                setState(() => _selectedDrawerIndex = 5);
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EmployeesListScreen()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.list_alt_outlined,
              title: 'Solicitudes',
              selected: _selectedDrawerIndex == 1,
              onTap: () {
                setState(() => _selectedDrawerIndex = 1);
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RequestsListScreen()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.event_available_outlined,
              title: 'Asistencia',
              selected: _selectedDrawerIndex == 4,
              onTap: () {
                setState(() => _selectedDrawerIndex = 4);
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              title: 'Ajustes',
              selected: _selectedDrawerIndex == 3,
              onTap: () {
                setState(() => _selectedDrawerIndex = 3);
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text('${AppConstants.appName} v0.1.0', style: AppTextStyles.small.copyWith(color: Colors.black54)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () async {
                      final logout = ref.read(logoutUseCaseProvider);
                      await logout.call();
                      ref.read(authSessionProvider.notifier).state = null;
                      if (!mounted) return;
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Salir'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cols = _columnsForWidth(constraints.maxWidth);
          final horizontalPadding = constraints.maxWidth < 600 ? 16.0 : 24.0;
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.6,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final m = metrics[index];
                      final icon = _iconForMetricKey(m.key);
                      final accent = _colorForMetricKey(m.key);
                      return SummaryCard(
                        title: m.title,
                        value: m.value,
                        subtitle: m.subtitle,
                        icon: icon,
                        accentColor: accent,
                      );
                    },
                    childCount: metrics.length,
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
                sliver: SliverToBoxAdapter(
                  child: ChartPlaceholder(title: 'Gráfico de estadísticas'),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 24),
                sliver: SliverToBoxAdapter(
                  child: ActivityList(activities: activities),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Metric> _buildMetrics(BuildContext context) {
    final att = ref.watch(attendanceControllerProvider);
    final employees = ref.watch(employeesProvider);
    final requests = ref.watch(requestsProvider);

    // Mapear empleado -> empresa
    final companyByEmployee = <String, String>{
      for (final e in employees) e.id: e.company,
    };

    // Calcular promedio semanal de tardanzas (minutos) por empresa, asumiendo jornada inicia 9:00
    int tardyMinutes(DateTime? entry) {
      if (entry == null) return 0;
      final scheduled = DateTime(entry.year, entry.month, entry.day, 9, 0);
      final diff = entry.difference(scheduled).inMinutes;
      return diff > 0 ? diff : 0;
    }

    final lateRecords = att.records.where((r) => r.status == AttendanceStatus.late).toList();
    final jaysaLate = lateRecords.where((r) => companyByEmployee[r.employeeId] == 'Jaysa Muebles').toList();
    final helacoLate = lateRecords.where((r) => companyByEmployee[r.employeeId] == 'Helaco').toList();
    final jaysaAvg = jaysaLate.isEmpty
        ? 0
        : (jaysaLate.map((r) => tardyMinutes(r.entry)).reduce((a, b) => a + b) / jaysaLate.length).round();
    final helacoAvg = helacoLate.isEmpty
        ? 0
        : (helacoLate.map((r) => tardyMinutes(r.entry)).reduce((a, b) => a + b) / helacoLate.length).round();

    // Vacaciones próximas (demo: contar solicitudes de vacaciones pendientes)
    final upcomingVacations = requests.where((r) => r.type == 'vacation' && r.status == 'pending').length;

    // Empleados en licencia y en vacaciones esta semana (desde asistencia)
    final onLeave = att.records.where((r) => r.status == AttendanceStatus.leave).map((r) => r.employeeId).toSet().length;
    final onVacation = att.records.where((r) => r.status == AttendanceStatus.vacation).map((r) => r.employeeId).toSet().length;

    // Permisos próximos (demo: solicitudes de permiso pendientes)
    final upcomingPermissions = requests.where((r) => r.type == 'permission' && r.status == 'pending').length;

    return [
      Metric(
        key: 'tardiness_avg',
        title: 'Promedio semanal de tardanzas',
        value: 'Jaysa: ${jaysaAvg}m • Helaco: ${helacoAvg}m',
        subtitle: 'Basado en entradas tardías de esta semana',
      ),
      Metric(
        key: 'upcoming_vacations',
        title: 'Vacaciones próximas',
        value: '$upcomingVacations empleados',
        subtitle: 'Solicitudes pendientes',
      ),
      Metric(
        key: 'on_leave',
        title: 'En licencia',
        value: '$onLeave empleados',
        subtitle: 'Semana actual',
      ),
      Metric(
        key: 'on_vacation',
        title: 'En vacaciones',
        value: '$onVacation empleados',
        subtitle: 'Semana actual',
      ),
      Metric(
        key: 'upcoming_permissions',
        title: 'Permisos próximos',
        value: '$upcomingPermissions solicitudes',
        subtitle: 'Pendientes de revisión',
      ),
    ];
  }

  IconData _iconForMetricKey(String key) {
    switch (key) {
      case 'requests':
        return Icons.list_alt_outlined;
      case 'approved':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.hourglass_bottom;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'tardiness_avg':
        return Icons.timer_outlined;
      case 'upcoming_vacations':
        return Icons.beach_access_outlined;
      case 'on_leave':
        return Icons.sick_outlined;
      case 'on_vacation':
        return Icons.airplane_ticket_outlined;
      case 'upcoming_permissions':
        return Icons.event_available_outlined;
      default:
        return Icons.insights_outlined;
    }
  }

  Color _colorForMetricKey(String key) {
    switch (key) {
      case 'requests':
        return AppColors.info;
      case 'approved':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.danger;
      case 'tardiness_avg':
        return AppColors.secondary;
      case 'upcoming_vacations':
        return AppColors.info;
      case 'on_leave':
        return AppColors.warning;
      case 'on_vacation':
        return AppColors.success;
      case 'upcoming_permissions':
        return AppColors.primary;
      default:
        return AppColors.secondary;
    }
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: selected,
      selectedTileColor: Colors.black12,
      onTap: onTap,
    );
  }
}