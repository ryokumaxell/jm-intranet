import 'package:j_intranet/features/auth/domain/repositories/auth_repository.dart';

class CreateUser {
  final AuthRepository repository;

  CreateUser(this.repository);

  Future<void> call(String email, String password, String role) {
    return repository.createUser(email, password, role);
  }
}