import 'package:flutter/material.dart';
import 'package:j_intranet/core/constants/app_colors.dart';
import '../../domain/entities/attendance_record.dart';

class WeeklyAttendanceTable extends StatelessWidget {
  const WeeklyAttendanceTable({
    super.key,
    required this.records,
    required this.range,
    this.onRegister,
  });

  final List<AttendanceRecord> records;
  final DateTimeRange range;
  final void Function(String employeeName, DateTime date)? onRegister;

  @override
  Widget build(BuildContext context) {
    final days = _daysInRange(range);
    final employees = _groupByEmployee(records);

    // Cabecera fija con SliverPersistentHeader y lista de filas debajo
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      cacheExtent: 720,
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _HeaderDelegate(days: days),
        ),
        SliverFixedExtentList(
          itemExtent: 72,
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final emp = employees[index];
              return RepaintBoundary(
                child: _EmployeeRow(
                  key: ValueKey(emp.id.isNotEmpty ? emp.id : emp.name),
                  employee: emp,
                  days: days,
                  onRegister: onRegister,
                ),
              );
            },
            childCount: employees.length,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            addSemanticIndexes: false,
          ),
        ),
      ],
    );
  }

  List<DateTime> _daysInRange(DateTimeRange r) {
    // Siempre mostrar de lunes a sábado de la semana del rango
    final anchor = DateTime(r.start.year, r.start.month, r.start.day);
    final monday = anchor.subtract(Duration(days: (anchor.weekday - DateTime.monday) % 7));
    return List.generate(6, (i) => DateTime(monday.year, monday.month, monday.day + i));
  }

  List<_EmployeeRowData> _groupByEmployee(List<AttendanceRecord> items) {
    final map = <String, _EmployeeRowData>{};
    for (final r in items) {
      final key = r.employeeId.isNotEmpty ? r.employeeId : r.employeeName;
      if (!map.containsKey(key)) {
        map[key] = _EmployeeRowData(id: r.employeeId, name: r.employeeName, department: r.department);
      }
      final dkey = DateTime(r.date.year, r.date.month, r.date.day);
      map[key]!.byDate[dkey] = r;
    }
    final list = map.values.toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.days});
  final List<DateTime> days;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _HeaderCell(label: 'Empleado', bold: true, withRightBorder: true),
          ),
          for (final d in days)
            Expanded(child: _HeaderDayCell(date: d)),
        ],
      ),
    );
  }
}

class _EmployeeRow extends StatelessWidget {
  const _EmployeeRow({super.key, required this.employee, required this.days, this.onRegister});
  final _EmployeeRowData employee;
  final List<DateTime> days;
  final void Function(String employeeName, DateTime date)? onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(employee.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
          for (final d in days)
            Expanded(
              child: _DayCell(
                record: employee.byDate[d],
                date: d,
                employeeName: employee.name,
                onRegister: onRegister,
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label, this.bold = false, this.withRightBorder = false});
  final String label;
  final bool bold;
  final bool withRightBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: withRightBorder ? Border(right: BorderSide(color: Colors.grey.shade300)) : null,
      ),
      child: Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
    );
  }
}

class _HeaderDayCell extends StatelessWidget {
  const _HeaderDayCell({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    const dayNames = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final name = dayNames[(date.weekday - 1).clamp(0, 6)];
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yy = (date.year % 100).toString().padLeft(2, '0');
    final dateStr = '$dd/$mm/$yy';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.shade300))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(dateStr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Text(name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.record, required this.date, required this.employeeName, this.onRegister});
  final AttendanceRecord? record;
  final DateTime date;
  final String employeeName;
  final void Function(String employeeName, DateTime date)? onRegister;

  @override
  Widget build(BuildContext context) {
    final entryText = _fmtTime(record?.entry);
    final exitText = _fmtTime(record?.exit);
    final entryDot = _entryDotColor(record);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.shade200))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Entrada  $entryText',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              if (entryDot != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _dot(entryDot),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: Text('Salida   $exitText', textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
            ],
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () {
              onRegister?.call(employeeName, date);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              minimumSize: const Size(0, 20),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: Colors.blue,
              textStyle: const TextStyle(fontSize: 11),
            ),
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  String _fmtTime(DateTime? t) {
    if (t == null) return '--:--';
    final hour = t.hour;
    final minute = t.minute.toString().padLeft(2, '0');
    final isPm = hour >= 12;
    int h12 = hour % 12;
    if (h12 == 0) h12 = 12;
    final suffix = isPm ? 'PM' : 'AM';
    return '$h12:$minute $suffix';
  }

  Color? _entryDotColor(AttendanceRecord? r) {
    if (r == null || r.entry == null) return AppColors.danger; // faltante
    if (r.status == AttendanceStatus.late) return Colors.amber; // tardanza
    return null; // puntual u otros -> sin punto
  }

  // No se muestran puntos para salida; solo se analiza entrada
}

class _EmployeeRowData {
  _EmployeeRowData({required this.id, required this.name, required this.department});
  final String id;
  final String name;
  final String department;
  final Map<DateTime, AttendanceRecord> byDate = {};
}

class StatusLegend extends StatelessWidget {
  const StatusLegend({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Text('Leyenda:', style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(width: 8),
        _LegendItem(color: Colors.amber, label: 'Tardanza'),
        SizedBox(width: 8),
        _LegendItem(color: AppColors.danger, label: 'Sin registro'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  _HeaderDelegate({required this.days});
  final List<DateTime> days;

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _Header(days: days);
  }

  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) {
    if (oldDelegate.days.length != days.length) return true;
    for (var i = 0; i < days.length; i++) {
      final a = oldDelegate.days[i];
      final b = days[i];
      if (a.year != b.year || a.month != b.month || a.day != b.day) return true;
    }
    return false;
  }
}