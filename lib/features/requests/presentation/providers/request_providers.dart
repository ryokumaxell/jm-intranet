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

// Refactor RequestsController to use AsyncNotifier
class RequestsNotifier extends AsyncNotifier<List<Request>> {
  late final RequestRepository _repository;

  @override
  Future<List<Request>> build() async {
    _repository = ref.watch(requestRepositoryProvider);
    return _repository.getRequests();
  }

  void load() {
    ref.invalidateSelf();
  }

  Future<void> add(String type) async {
    state = const AsyncValue.loading();
    try {
      final req = await _repository.createRequest(type: type);
      state = AsyncValue.data([...state.value!, req]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> cancel(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.cancelRequest(id);
      state = AsyncValue.data(state.value!.where((e) => e.id != id).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final requestsProvider = AsyncNotifierProvider<RequestsNotifier, List<Request>>(
  RequestsNotifier.new,
);