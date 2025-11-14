import '../entities/request.dart';
import '../repositories/request_repository.dart';

class CreateRequest {
  final RequestRepository repository;
  const CreateRequest(this.repository);

  Future<Request> call({
    required String type,
    required String employeeId,
    required String employeeName,
    required String employeeEmail,
    required DateTime startDate,
    DateTime? endDate,
    required String reason,
  }) {
    return repository.createRequest(
      type: type,
      employeeId: employeeId,
      employeeName: employeeName,
      employeeEmail: employeeEmail,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );
  }
}
