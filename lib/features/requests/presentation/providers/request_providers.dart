import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_intranet/core/providers/dio_provider.dart';
import 'package:j_intranet/features/auth/presentation/providers/auth_providers.dart';
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
  @override
  Future<List<Request>> build() async {
    final repository = ref.watch(requestRepositoryProvider);
    final session = ref.watch(authSessionProvider);
    final employeeId = session?.user.id;
    return repository.getRequests(employeeId: employeeId);
  }

  void load() {
    ref.invalidateSelf();
  }

  Future<void> add({
    required String type,
    required String employeeId,
    required String employeeName,
    required String employeeEmail,
    required DateTime startDate,
    DateTime? endDate,
    required String reason,
  }) async {
    try {
      final repository = ref.read(requestRepositoryProvider);
      final previous = state.value ?? const <Request>[];
      final req = await repository.createRequest(
        type: type,
        employeeId: employeeId,
        employeeName: employeeName,
        employeeEmail: employeeEmail,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );
      state = AsyncValue.data([...previous, req]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> cancel(String id) async {
    try {
      final repository = ref.read(requestRepositoryProvider);
      await repository.cancelRequest(id);
      final previous = state.value ?? const <Request>[];
      state = AsyncValue.data(previous.where((e) => e.id != id).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final requestsProvider = AsyncNotifierProvider<RequestsNotifier, List<Request>>(
  RequestsNotifier.new,
);
