import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_intranet/core/providers/dio_provider.dart';

import '../../domain/entities/request.dart';
import '../../domain/repositories/request_repository.dart';
import '../../domain/usecases/get_requests.dart';
import '../../domain/usecases/create_request.dart';
import '../../domain/usecases/cancel_request.dart';
import '../../data/datasources/requests_remote_data_source.dart';
import '../../data/repositories/request_repository_impl.dart';

final requestRepositoryProvider = Provider<RequestRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final ds = RequestsRemoteDataSource(dio);
  return RequestRepositoryImpl(ds);
});

final getRequestsUseCaseProvider = Provider<GetRequests>((ref) {
  final repo = ref.watch(requestRepositoryProvider);
  return GetRequests(repo);
});

final createRequestUseCaseProvider = Provider<CreateRequest>((ref) {
  final repo = ref.watch(requestRepositoryProvider);
  return CreateRequest(repo);
});

final cancelRequestUseCaseProvider = Provider<CancelRequest>((ref) {
  final repo = ref.watch(requestRepositoryProvider);
  return CancelRequest(repo);
});

class RequestsController extends StateNotifier<List<Request>> {
  RequestsController(this._repository) : super(const []);

  final RequestRepository _repository;

  Future<void> load() async {
    final items = await _repository.getRequests();
    state = items;
  }

  Future<void> add(String type) async {
    final req = await _repository.createRequest(type: type);
    state = [...state, req];
  }

  Future<void> cancel(String id) async {
    await _repository.cancelRequest(id);
    state = state.where((e) => e.id != id).toList();
  }
}

final requestsProvider =
    StateNotifierProvider<RequestsController, List<Request>>((ref) {
  final repo = ref.watch(requestRepositoryProvider);
  return RequestsController(repo);
});