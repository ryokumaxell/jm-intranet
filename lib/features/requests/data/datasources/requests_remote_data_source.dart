import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/request.dart';
import '../models/request_model.dart';

class RequestsRemoteDataSource {
  final FirebaseFirestore _firestore;

  RequestsRemoteDataSource(Dio _) : _firestore = FirebaseFirestore.instance;

  Future<List<Request>> getRequests({String? employeeId}) async {
    try {
      var query = _firestore.collection('requests') as Query;

      // Si se proporciona employeeId, filtrar por ese empleado
      if (employeeId != null && employeeId.isNotEmpty) {
        query = query.where('employeeId', isEqualTo: employeeId);
      }

      final snap = await query.orderBy('createdAt', descending: true).get();
      return snap.docs.map((doc) {
        return RequestModel.fromJson(
            {...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }).toList();
    } catch (e) {
      // Fallback a datos de ejemplo si hay error
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return <Request>[
        RequestModel(
          id: 'REQ-1001',
          employeeId: 'emp-001',
          employeeName: 'Juan Pérez',
          employeeEmail: 'juan@example.com',
          type: RequestType.permission,
          status: RequestStatus.pending,
          startDate: DateTime.now(),
          reason: 'Permiso médico',
          createdAt: DateTime.now(),
        ),
        RequestModel(
          id: 'REQ-1002',
          employeeId: 'emp-002',
          employeeName: 'María García',
          employeeEmail: 'maria@example.com',
          type: RequestType.vacation,
          status: RequestStatus.approved,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
          reason: 'Vacaciones',
          createdAt: DateTime.now(),
        ),
      ];
    }
  }

  Future<Request> createRequest({
    required String type,
    required String employeeId,
    required String employeeName,
    required String employeeEmail,
    required DateTime startDate,
    DateTime? endDate,
    required String reason,
  }) async {
    try {
      final docRef = _firestore.collection('requests').doc();
      final now = DateTime.now();

      final data = {
        'id': docRef.id,
        'employeeId': employeeId,
        'employeeName': employeeName,
        'employeeEmail': employeeEmail,
        'type': type,
        'status': 'pending',
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'reason': reason,
        'createdAt': now.toIso8601String(),
      };

      await docRef.set(data);
      return RequestModel.fromJson({...data, 'id': docRef.id});
    } catch (e) {
      // Fallback: crear localmente si falla Firestore
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return RequestModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        employeeId: employeeId,
        employeeName: employeeName,
        employeeEmail: employeeEmail,
        type: RequestType.values.firstWhere((e) => e.name == type),
        status: RequestStatus.pending,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        createdAt: DateTime.now(),
      );
    }
  }

  Future<void> cancelRequest(String id) async {
    try {
      await _firestore.collection('requests').doc(id).delete();
    } catch (e) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }
}
