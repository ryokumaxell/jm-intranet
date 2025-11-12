import 'package:flutter/material.dart';
import 'package:j_intranet/core/constants/app_colors.dart';
import '../../domain/entities/attendance_record.dart';

class StatusBadge extends StatelessWidget {
  final AttendanceStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final data = _dataFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: data.color.withAlpha(31),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: data.color.withAlpha(82)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 16, color: data.color),
          const SizedBox(width: 6),
          Text(data.label, style: TextStyle(color: data.color, fontSize: 12)),
        ],
      ),
    );
  }

  _BadgeData _dataFor(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.punctual:
        return _BadgeData('Puntual', AppColors.success, Icons.check_circle);
      case AttendanceStatus.late:
        return _BadgeData('Tardanza', AppColors.warning, Icons.schedule);
      case AttendanceStatus.absent:
        return _BadgeData('Falta', AppColors.danger, Icons.cancel);
      case AttendanceStatus.vacation:
        return _BadgeData('Vacaciones', AppColors.info, Icons.beach_access);
      case AttendanceStatus.leave:
        return _BadgeData('Permiso', AppColors.secondary, Icons.description);
    }
  }
}

class _BadgeData {
  final String label;
  final Color color;
  final IconData icon;
  const _BadgeData(this.label, this.color, this.icon);
}