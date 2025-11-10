import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class Login {
  final AuthRepository repository;
  const Login(this.repository);

  Future<AuthSession> call(String email, String password) {
    return repository.login(email: email, password: password);
  }
}