import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Future<AuthSession> login({required String email, required String password}) {
    return remote.login(email, password);
  }

  @override
  Future<void> logout() {
    return remote.logout();
  }

  @override
  Future<User?> getCurrentUser() {
    return remote.getCurrentUser();
  }

  @override
  Future<User> createUser(
      {required String email,
      required String password,
      required String role,
      required List<String> companies}) {
    return remote.createUser(
        email: email, password: password, role: role, companies: companies);
  }
}
