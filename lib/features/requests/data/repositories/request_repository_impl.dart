import '../../domain/entities/request.dart';
import '../../domain/repositories/request_repository.dart';
import '../datasources/requests_remote_data_source.dart';

class RequestRepositoryImpl implements RequestRepository {
  final RequestsRemoteDataSource remote;
  RequestRepositoryImpl(this.remote);

  @override
  Future<List<Request>> getRequests() {
    return remote.getRequests();
  }

  @override
  Future<Request> createRequest({required String type}) {
    return remote.createRequest(type: type);
  }

  @override
  Future<void> cancelRequest(String id) {
    return remote.cancelRequest(id);
  }
}