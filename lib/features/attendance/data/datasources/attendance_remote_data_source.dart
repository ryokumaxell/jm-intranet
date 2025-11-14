import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/attendance_record.dart';
import '../models/attendance_record_model.dart';

class AttendanceRemoteDataSource {
  final Dio dio;
  AttendanceRemoteDataSource(this.dio);

  Future<List<AttendanceRecord>> fetchRecords(
      {required DateTimeRange range,
      String? department,
      String query = '',
      String? company}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final sample = <AttendanceRecordModel>[
      AttendanceRecordModel(
        id: 'r1',
        employeeName: 'Juan Pérez',
        employeeId: 'EMP-001',
        department: 'Ventas',
        date: now.subtract(const Duration(days: 1)),
        entry: DateTime(now.year, now.month, now.day - 1, 9, 0),
        exit: DateTime(now.year, now.month, now.day - 1, 17, 0),
        hoursWorked: 8,
        status: AttendanceStatus.punctual,
        company: 'Jaysa Muebles',
      ),
      AttendanceRecordModel(
        id: 'r2',
        employeeName: 'María López',
        employeeId: 'EMP-002',
        department: 'Recursos Humanos',
        date: now.subtract(const Duration(days: 2)),
        entry: DateTime(now.year, now.month, now.day - 2, 9, 30),
        exit: DateTime(now.year, now.month, now.day - 2, 17, 0),
        hoursWorked: 7.5,
        status: AttendanceStatus.late,
        company: 'Helaco',
      ),
      AttendanceRecordModel(
        id: 'r3',
        employeeName: 'Carlos Ruiz',
        employeeId: 'EMP-003',
        department: 'Operaciones',
        date: now.subtract(const Duration(days: 3)),
        entry: null,
        exit: null,
        hoursWorked: 0,
        status: AttendanceStatus.absent,
        company: 'Jaysa Muebles',
      ),
    ];

    return sample
        .where((e) => (department == null || e.department == department))
        .where((e) => (company == null || e.company == company))
        .where((e) =>
            query.isEmpty ||
            e.employeeName.toLowerCase().contains(query.toLowerCase()) ||
            e.employeeId.toLowerCase().contains(query.toLowerCase()))
        .where((e) =>
            e.date.isAfter(range.start.subtract(const Duration(days: 1))) &&
            e.date.isBefore(range.end.add(const Duration(days: 1))))
        .toList();
  }
}
