import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_intranet/core/providers/dio_provider.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/create_user.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final ds = AuthRemoteDataSource(dio);
  return AuthRepositoryImpl(ds);
});

final loginUseCaseProvider = Provider<Login>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return Login(repo);
});

final logoutUseCaseProvider = Provider<Logout>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return Logout(repo);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUser>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return GetCurrentUser(repo);
});

final createUserUseCaseProvider = Provider<CreateUser>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return CreateUser(repo);
});

class AuthSessionNotifier extends StateNotifier<AuthSession?> {
  AuthSessionNotifier() : super(null);

  void setSession(AuthSession? session) {
    state = session;
  }
}

final authSessionProvider = StateNotifierProvider<AuthSessionNotifier, AuthSession?>(
  (ref) => AuthSessionNotifier(),
);