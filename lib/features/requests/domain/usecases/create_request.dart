import '../entities/request.dart';
import '../repositories/request_repository.dart';

class CreateRequest {
  final RequestRepository repository;
  const CreateRequest(this.repository);

  Future<Request> call({required String type}) {
    return repository.createRequest(type: type);
  }
}