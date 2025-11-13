import 'package:flutter/material.dart';
import '../../domain/entities/attendance_record.dart';
import 'status_badge.dart';

class CustomDataTable extends StatefulWidget {
  final List<AttendanceRecord> records;
  final void Function(String column) onSort;
  final void Function(int page) onPage;
  const CustomDataTable({super.key, required this.records, required this.onSort, required this.onPage});

  @override
  State<CustomDataTable> createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<CustomDataTable> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, bool> _hoverMap = {};
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _HeaderDelegate(onSort: widget.onSort),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final r = widget.records[index];
              final key = r.id;
              final hovered = _hoverMap[key] == true;
              return MouseRegion(
                onEnter: (_) => setState(() => _hoverMap[key] = true),
                onExit: (_) => setState(() => _hoverMap[key] = false),
                child: _RowItem(record: r, hovered: hovered),
              );
            },
            childCount: widget.records.length,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: _page <= 0 ? null : () => _changePage(_page - 1), child: const Text('Anterior')),
                const SizedBox(width: 8),
                Text('Página ${_page + 1}'),
                const SizedBox(width: 8),
                TextButton(onPressed: () => _changePage(_page + 1), child: const Text('Siguiente')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _changePage(int p) {
    setState(() => _page = p);
    widget.onPage(p);
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final void Function(String column) onSort;
  _HeaderDelegate({required this.onSort});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 2 : 0,
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 56,
        child: Row(
          children: [
            _HeaderCell(label: 'Empleado', flex: 2, onTap: () => onSort('name')),
            _HeaderCell(label: 'Departamento', onTap: () => onSort('department')),
            _HeaderCell(label: 'Fecha', center: true, onTap: () => onSort('date')),
            _HeaderCell(label: 'Entrada', center: true, onTap: () => onSort('entry')),
            _HeaderCell(label: 'Salida', center: true, onTap: () => onSort('exit')),
            _HeaderCell(label: 'Horas', center: true),
            _HeaderCell(label: 'Estado', center: true, onTap: () => onSort('status')),
            const SizedBox(width: 80, child: Center(child: Text('Acciones'))),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 56;
  @override
  double get minExtent => 56;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final VoidCallback? onTap;
  final bool center;
  const _HeaderCell({required this.label, this.flex = 1, this.onTap, this.center = false});

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        if (onTap != null) const Icon(Icons.unfold_more, size: 16),
      ],
    );
    return Expanded(
      flex: flex,
      child: InkWell(onTap: onTap, child: child),
    );
  }
}

class _RowItem extends StatefulWidget {
  final AttendanceRecord record;
  final bool hovered;
  const _RowItem({required this.record, required this.hovered});

  @override
  State<_RowItem> createState() => _RowItemState();
}

class _RowItemState extends State<_RowItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 60,
          color: widget.hovered ? Colors.black.withValues(alpha: 0.02) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text('${widget.record.employeeName}\n${widget.record.employeeId}', maxLines: 2),
              ),
              Expanded(child: Text(widget.record.department)),
              Expanded(child: Center(child: Text(_fmtDate(widget.record.date), textAlign: TextAlign.center))),
              Expanded(child: Center(child: Text(_fmtTime(widget.record.entry), textAlign: TextAlign.center))),
              Expanded(child: Center(child: Text(_fmtTime(widget.record.exit), textAlign: TextAlign.center))),
              Expanded(child: Center(child: Text(widget.record.hoursWorked.toStringAsFixed(1), textAlign: TextAlign.center))),
              Expanded(child: Center(child: StatusBadge(status: widget.record.status))),
              SizedBox(
                width: 80,
                child: Row(
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.edit, size: 20)),
                    IconButton(onPressed: () => setState(() => _expanded = !_expanded), icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 20)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_expanded)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(radius: 24, child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detalle de asistencia', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Departamento: ${widget.record.department}'),
                      Text('Fecha: ${_fmtDate(widget.record.date)}'),
                      Text('Entrada: ${_fmtTime(widget.record.entry)}'),
                      Text('Salida: ${_fmtTime(widget.record.exit)}'),
                      const SizedBox(height: 8),
                      const Text('Historial reciente (últimos 5 registros):'),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (int i = 0; i < 5; i++) Chip(label: Text('Registro ${i + 1}')),
                      ]),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Observaciones'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        OutlinedButton(onPressed: () {}, child: const Text('Editar')),
                        const SizedBox(width: 8),
                        ElevatedButton(onPressed: () {}, child: const Text('Guardar')),
                      ])
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _fmtDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _fmtTime(DateTime? t) => t == null ? '-' : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}