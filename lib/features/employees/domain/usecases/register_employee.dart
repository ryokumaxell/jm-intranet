import 'package:j_intranet/features/auth/domain/repositories/auth_repository.dart';
import 'package:j_intranet/features/auth/domain/entities/user.dart';

class RegisterEmployee {
  final AuthRepository repository;

  RegisterEmployee(this.repository);

  Future<User> call({
    required String name,
    required String email,
    required String password,
    required String role,
    required String company,
  }) async {
    // Here we can add more complex logic if needed, e.g., storing employee details
    // in a separate collection or performing additional validation.
    return await repository.createUser(email: email, password: password, role: role, company: company);
  }
}