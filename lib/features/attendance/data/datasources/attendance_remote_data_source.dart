import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance_record.dart';
import '../models/attendance_record_model.dart';

class AttendanceRemoteDataSource {
  final Dio dio;
  final FirebaseFirestore _firestore;

  AttendanceRemoteDataSource(this.dio)
      : _firestore = FirebaseFirestore.instance;

  Future<List<AttendanceRecord>> fetchRecords(
      {required DateTimeRange range,
      String? department,
      String query = '',
      String? company}) async {
    try {
      // Obtener registros de asistencia desde Firestore
      Query<Map<String, dynamic>> query_ref =
          _firestore.collection('attendance_records');

      // Filtrar por compañía si se proporciona
      if (company != null && company.isNotEmpty) {
        query_ref = query_ref.where('company', isEqualTo: company);
      }

      // Filtrar por rango de fechas
      query_ref = query_ref
          .where('date',
              isGreaterThanOrEqualTo:
                  range.start.subtract(const Duration(days: 1)))
          .where('date',
              isLessThanOrEqualTo: range.end.add(const Duration(days: 1)));

      final snap = await query_ref.get();
      final records = snap.docs
          .map((doc) => AttendanceRecordModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      // Aplicar filtros adicionales
      return records
          .where((e) => (department == null || e.department == department))
          .where((e) =>
              query.isEmpty ||
              e.employeeName.toLowerCase().contains(query.toLowerCase()) ||
              e.employeeId.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print('Error fetching attendance records: $e');
      // Fallback a datos de prueba si falla Firestore
      return _getFallbackData(range, department, query, company);
    }
  }

  List<AttendanceRecord> _getFallbackData(
    DateTimeRange range,
    String? department,
    String query,
    String? company,
  ) {
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
