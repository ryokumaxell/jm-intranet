import 'package:flutter/material.dart';
import '../../domain/entities/attendance_record.dart';
import 'status_badge.dart';

class EmployeeCard extends StatelessWidget {
  final AttendanceRecord record;
  const EmployeeCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.employeeName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(record.employeeId, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  StatusBadge(status: record.status),
                ],
              ),
            ),
            Text('${record.hoursWorked.toStringAsFixed(1)} h'),
          ],
        ),
      ),
    );
  }
}