import '../entities/request.dart';

abstract class RequestRepository {
  Future<List<Request>> getRequests({String? employeeId});
  Future<Request> createRequest({
    required String type,
    required String employeeId,
    required String employeeName,
    required String employeeEmail,
    required DateTime startDate,
    DateTime? endDate,
    required String reason,
  });
  Future<void> cancelRequest(String id);
}
