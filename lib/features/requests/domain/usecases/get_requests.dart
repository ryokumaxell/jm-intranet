import '../entities/request.dart';
import '../repositories/request_repository.dart';

class GetRequests {
  final RequestRepository repository;
  const GetRequests(this.repository);

  Future<List<Request>> call() {
    return repository.getRequests();
  }
}