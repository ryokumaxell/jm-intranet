import 'package:dio/dio.dart';

import '../models/request_model.dart';

class RequestsRemoteDataSource {
  // ignore: unused_field
  final Dio _dio;
  RequestsRemoteDataSource(this._dio);

  Future<List<RequestModel>> getRequests() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // Datos de ejemplo para demo del panel
    return const <RequestModel>[
      RequestModel(id: 'REQ-1001', type: 'permission', status: 'pending'),
      RequestModel(id: 'REQ-1002', type: 'vacation', status: 'approved'),
      RequestModel(id: 'REQ-1003', type: 'vacation', status: 'pending'),
      RequestModel(id: 'REQ-2001', type: 'tardiness', status: 'pending'),
      RequestModel(id: 'REQ-2002', type: 'tardiness', status: 'pending'),
    ];
  }

  Future<RequestModel> createRequest({required String type}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return RequestModel(id: DateTime.now().millisecondsSinceEpoch.toString(), type: type, status: 'pending');
  }

  Future<void> cancelRequest(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}