import '../repositories/request_repository.dart';

class CancelRequest {
  final RequestRepository repository;
  const CancelRequest(this.repository);

  Future<void> call(String id) {
    return repository.cancelRequest(id);
  }
}