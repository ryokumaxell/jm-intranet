import 'package:dio/dio.dart';
import 'package:j_intranet/core/network/endpoints.dart';

import '../models/request_model.dart';

class RequestsRemoteDataSource {
  final Dio _dio;
  RequestsRemoteDataSource(this._dio);

  Future<List<RequestModel>> getRequests() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const <RequestModel>[];
  }

  Future<RequestModel> createRequest({required String type}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return RequestModel(id: DateTime.now().millisecondsSinceEpoch.toString(), type: type, status: 'pending');
  }

  Future<void> cancelRequest(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}