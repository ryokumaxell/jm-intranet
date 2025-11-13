import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/employee.dart';
import '../models/employee_model.dart';

class EmployeesRemoteDataSource {
  // ignore: unused_field
  final Dio _dio;
  final FirebaseFirestore _firestore;
  EmployeesRemoteDataSource(this._dio) : _firestore = FirebaseFirestore.instance;

  Future<List<Employee>> getEmployees() async {
    final companyIds = <String>['jaysa_muebles', 'helaco'];
    final snapshots = await Future.wait(
      companyIds.map((c) => _firestore.collection('companies').doc(c).collection('employees').get()),
    );
    final docs = snapshots.expand((s) => s.docs);
    return docs
        .map((d) {
          final data = d.data();
          return EmployeeModel(
            id: d.id,
            name: (data['name'] ?? '').toString(),
            department: (data['department'] ?? '').toString(),
            company: (data['company'] ?? '').toString(),
          );
        })
        .toList();
  }
}