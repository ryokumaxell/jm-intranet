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

  int _columnsForWidth(double w) {
    if (w < 600) return 1; // móviles
    if (w < 1024) return 2; // tablets
    if (w < 1440) return 3; // escritorio mediano
    return 4; // escritorio ancho
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(dashboardMetricsProvider);
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
            const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          Text(session?.user.name ?? 'Invitado', style: AppTextStyles.body),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Asistencia',
            icon: const Icon(Icons.event_available_outlined),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AttendanceScreen()));
            },
          ),
          PopupMenuButton<String>(
            tooltip: 'Opciones',
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'perfil':
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  break;
                case 'solicitudes':
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RequestsListScreen()));
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'perfil', child: Text('Mi Perfil')),
              PopupMenuItem(value: 'solicitudes', child: Text('Solicitudes')),
            ],
          ),
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