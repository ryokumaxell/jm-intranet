import 'package:dio/dio.dart';

import '../models/employee_model.dart';

class EmployeesRemoteDataSource {
  // ignore: unused_field
  final Dio _dio;
  EmployeesRemoteDataSource(this._dio);

  Future<List<EmployeeModel>> getEmployees() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const [
      EmployeeModel(id: 'EMP-001', name: 'Juan Pérez', department: 'Ventas', company: 'Jaysa Muebles'),
      EmployeeModel(id: 'EMP-002', name: 'María López', department: 'Recursos Humanos', company: 'Jaysa Muebles'),
      EmployeeModel(id: 'EMP-003', name: 'Carlos Ruiz', department: 'Operaciones', company: 'Helaco'),
      EmployeeModel(id: 'EMP-004', name: 'Ana García', department: 'Logística', company: 'Helaco'),
    ];
  }
}