import 'package:dio/dio.dart';

import '../models/request_model.dart';
import '../../domain/entities/request.dart';

class RequestsRemoteDataSource {
  // ignore: unused_field
  final Dio _dio;
  RequestsRemoteDataSource(this._dio);

  Future<List<RequestModel>> getRequests() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // Datos de ejemplo para demo del panel
    return const <RequestModel>[
      RequestModel(id: 'REQ-1001', type: RequestType.permission, status: RequestStatus.pending),
      RequestModel(id: 'REQ-1002', type: RequestType.vacation, status: RequestStatus.approved),
      RequestModel(id: 'REQ-1003', type: RequestType.vacation, status: RequestStatus.pending),
      RequestModel(id: 'REQ-2001', type: RequestType.tardiness, status: RequestStatus.pending),
      RequestModel(id: 'REQ-2002', type: RequestType.tardiness, status: RequestStatus.pending),
    ];
  }

  Future<RequestModel> createRequest({required String type}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return RequestModel(id: DateTime.now().millisecondsSinceEpoch.toString(), type: RequestType.values.firstWhere((e) => e.name == type), status: RequestStatus.pending);
  }

  Future<void> cancelRequest(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}