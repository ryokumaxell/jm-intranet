import 'package:j_intranet/features/auth/domain/repositories/auth_repository.dart';

class CreateUser {
  final AuthRepository repository;

  CreateUser(this.repository);

  Future<void> call(
      String email, String password, String role, List<String> companies) {
    return repository.createUser(
        email: email, password: password, role: role, companies: companies);
  }
}
