import 'package:flutter/material.dart';
import '../widgets/register_options_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_intranet/core/constants/app_colors.dart';
import 'package:j_intranet/core/constants/app_text_styles.dart';
import 'package:j_intranet/core/constants/app_constants.dart';
import 'package:j_intranet/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:j_intranet/features/requests/presentation/screens/requests_list_screen.dart';
import 'package:j_intranet/features/employees/presentation/screens/employees_list_screen.dart';
import 'package:j_intranet/features/settings/presentation/screens/settings_screen.dart';
import 'package:j_intranet/features/auth/presentation/providers/auth_providers.dart';
import 'package:j_intranet/features/attendance/domain/entities/attendance_record.dart';

import '../providers/attendance_providers.dart';
// import '../widgets/date_range_selector.dart';
// import '../widgets/custom_data_table.dart';
import '../widgets/weekly_attendance_table.dart';
// import '../widgets/stat_card.dart';
// import '../widgets/manual_entry_modal.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String? _dept;
  String _selectedCompany = 'Jaysa Muebles'; // Usar nombre de compañía

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      ref
          .read(attendanceControllerProvider.notifier)
          .setQuery(_searchCtrl.text);
    });
    // Inicializar compañía según el usuario y cargar datos de JSON
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final session = ref.read(authSessionProvider);

      // Seleccionar compañía
      if (session?.user.companies != null &&
          session!.user.companies!.isNotEmpty) {
        // Si el usuario solo tiene acceso a una compañía, seleccionarla automáticamente
        if (session.user.companies!.length == 1) {
          _selectedCompany = session.user.companies![0];
        } else {
          // Si tiene acceso a múltiples, seleccionar Helaco por defecto si está disponible
          if (session.user.companies!.contains('Helaco')) {
            _selectedCompany = 'Helaco';
          } else {
            _selectedCompany = session.user.companies![0];
          }
        }

        ref
            .read(attendanceControllerProvider.notifier)
            .setCompany(_selectedCompany);
        setState(() {});
      }

      // Los datos se cargarán automáticamente desde assets
      // cuando se seleccione la semana correcta
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = ref.read(attendanceControllerProvider.notifier);
    final session = ref.watch(authSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 2,
        title: const Text('Control de Asistencia',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          const Icon(Icons.notifications_none),
          const SizedBox(width: 8),
          Text(session?.user.email ?? 'Invitado', style: AppTextStyles.body),
          const SizedBox(width: 12),
        ],
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
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
              leading: const Icon(Icons.event_available_outlined),
              title: const Text('Asistencia'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
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
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RequestsListScreen()),
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
      // floatingActionButton eliminado a solicitud: no se muestra botón flotante en Asistencia
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(
                  session: session,
                  searchCtrl: _searchCtrl,
                  selectedCompany: _selectedCompany,
                  onSelectCompany: (c) {
                    setState(() => _selectedCompany = c);
                    ctrl.setCompany(c);
                  },
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _TableSection(
                      onRegister: (employeeName, date) {
                        showDialog(
                          context: context,
                          builder: (_) => RegisterOptionsModal(
                              employeeName: employeeName, date: date),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.session, required this.searchCtrl, required this.selectedCompany, required this.onSelectCompany});
  final dynamic session;
  final TextEditingController searchCtrl;
  final String selectedCompany;
  final void Function(String company) onSelectCompany;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        if (session?.user.companies != null && session!.user.companies!.length > 1) ...[
          if (session.user.companies!.contains('Jaysa Muebles'))
            ChoiceChip(
              selected: selectedCompany == 'Jaysa Muebles',
              label: const Text('Jaysa Muebles'),
              onSelected: (_) {
                onSelectCompany('Jaysa Muebles');
              },
            ),
          if (session.user.companies!.contains('Jaysa Muebles')) const SizedBox(width: 8),
          if (session.user.companies!.contains('Helaco'))
            ChoiceChip(
              selected: selectedCompany == 'Helaco',
              label: const Text('Helaco'),
              onSelected: (_) {
                onSelectCompany('Helaco');
              },
            ),
        ] else if (session?.user.companies != null && session!.user.companies!.length == 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Compañía: ${session.user.companies![0]}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        const SizedBox(width: 12),
        const StatusLegend(),
        const Spacer(),
        SizedBox(
          width: 280,
          child: TextField(
            controller: searchCtrl,
            decoration: const InputDecoration(
              hintText: 'Buscar empleado...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const _WeekNavigator(),
      ],
    );
  }
}

class _WeekNavigator extends ConsumerWidget {
  const _WeekNavigator();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(attendanceControllerProvider.notifier);
    final range = ref.watch(
      attendanceControllerProvider.select((state) => state.maybeWhen(
            data: (_) => ctrl.filters.dateRange,
            orElse: () => ctrl.filters.dateRange,
          )),
    );
    return _WeekLabel(range: range, onPrev: ctrl.previousWeek, onNext: ctrl.nextWeek);
  }
}

class _TableSection extends ConsumerWidget {
  const _TableSection({required this.onRegister});
  final void Function(String employeeName, DateTime date) onRegister;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(attendanceControllerProvider.notifier);
    final isLoading = ref.watch(
      attendanceControllerProvider.select((state) => state.maybeWhen(loading: () => true, orElse: () => false)),
    );
    final records = ref.watch(
      attendanceControllerProvider.select((state) => state.maybeWhen(data: (records) => records, orElse: () => <AttendanceRecord>[])),
    );
    if (isLoading) return const _TableSkeletonLoader();
    return WeeklyAttendanceTable(records: records, range: ctrl.filters.dateRange, onRegister: onRegister);
  }
}

class _TableSkeletonLoader extends StatelessWidget {
  const _TableSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(16))),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 12, color: Colors.black12)),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 12, color: Colors.black12)),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 12, color: Colors.black12)),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 12, color: Colors.black12)),
            ],
          ),
        );
      },
    );
  }
}

class _WeekLabel extends StatelessWidget {
  const _WeekLabel(
      {required this.range, required this.onPrev, required this.onNext});
  final DateTimeRange range;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) {
    String fmt(DateTime d) {
      final dd = d.day.toString().padLeft(2, '0');
      final mm = d.month.toString().padLeft(2, '0');
      final yy = (d.year % 100).toString().padLeft(2, '0');
      return '$dd/$mm/$yy';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      constraints: const BoxConstraints(minWidth: 260),
      decoration: BoxDecoration(
          color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: 'Semana anterior',
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
          ),
          Text(fmt(range.start),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Text(fmt(range.end),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          IconButton(
            tooltip: 'Próxima semana',
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}
