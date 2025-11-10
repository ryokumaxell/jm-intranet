import '../entities/request.dart';

abstract class RequestRepository {
  Future<List<Request>> getRequests();
  Future<Request> createRequest({required String type});
  Future<void> cancelRequest(String id);
}