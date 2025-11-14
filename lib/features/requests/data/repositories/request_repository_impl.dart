import '../../domain/entities/request.dart';
import '../../domain/repositories/request_repository.dart';
import '../datasources/requests_remote_data_source.dart';

class RequestRepositoryImpl implements RequestRepository {
  final RequestsRemoteDataSource remote;
  RequestRepositoryImpl(this.remote);

  @override
  Future<List<Request>> getRequests({String? employeeId}) {
    return remote.getRequests(employeeId: employeeId);
  }

  @override
  Future<Request> createRequest({
    required String type,
    required String employeeId,
    required String employeeName,
    required String employeeEmail,
    required DateTime startDate,
    DateTime? endDate,
    required String reason,
  }) {
    return remote.createRequest(
      type: type,
      employeeId: employeeId,
      employeeName: employeeName,
      employeeEmail: employeeEmail,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );
  }

  @override
  Future<void> cancelRequest(String id) {
    return remote.cancelRequest(id);
  }
}
