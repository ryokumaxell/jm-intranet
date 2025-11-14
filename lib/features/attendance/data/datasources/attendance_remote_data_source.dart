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
      // Obtener todos los empleados de la compañía
      final employees = await _getEmployeesByCompany(company);

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

      // Crear registros vacíos para empleados sin asistencia
      final recordsByEmployee = <String, List<AttendanceRecord>>{};
      for (final record in records) {
        final key = record.employeeName;
        recordsByEmployee.putIfAbsent(key, () => []).add(record);
      }

      // Agregar empleados sin registros
      final allRecords = List<AttendanceRecord>.from(records);
      for (final employee in employees) {
        if (!recordsByEmployee.containsKey(employee['name'])) {
          // Crear un registro vacío para el empleado
          allRecords.add(AttendanceRecordModel(
            id: '${employee['name']}_placeholder',
            employeeName: employee['name'],
            employeeId: employee['id'],
            department: employee['department'] ?? 'General',
            date: range.start,
            entry: null,
            exit: null,
            hoursWorked: 0,
            status: AttendanceStatus.absent,
            company: company,
          ));
        }
      }

      // Aplicar filtros adicionales
      return allRecords
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

  /// Obtiene todos los empleados de una compañía desde Firestore
  Future<List<Map<String, dynamic>>> _getEmployeesByCompany(
      String? company) async {
    try {
      if (company == null || company.isEmpty) {
        return [];
      }

      // Mapear nombre de compañía a ID en Firestore
      final companyId = company == 'Jaysa Muebles' ? 'jaysa_muebles' : 'helaco';

      final snap = await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .get();

      return snap.docs
          .map((doc) => {
                'id': doc.id,
                'name': (doc.data()['name'] ?? '').toString(),
                'department':
                    (doc.data()['department'] ?? 'General').toString(),
                'company': company,
              })
          .toList();
    } catch (e) {
      print('Error fetching employees: $e');
      return [];
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
