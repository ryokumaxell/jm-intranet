import '../entities/auth_session.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<User> createUser({required String email, required String password, required String role, required String company});
}