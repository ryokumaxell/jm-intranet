import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_intranet/core/providers/dio_provider.dart';
import 'package:j_intranet/features/auth/presentation/providers/auth_providers.dart';
import 'package:j_intranet/features/employees/domain/usecases/register_employee.dart';

import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../../data/datasources/employees_remote_data_source.dart';
import '../../data/repositories/employee_repository_impl.dart';

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final ds = EmployeesRemoteDataSource(dio);
  return EmployeeRepositoryImpl(ds);
});

final registerEmployeeUseCaseProvider = Provider<RegisterEmployee>(
  (ref) => RegisterEmployee(ref.watch(authRepositoryProvider)),
);

// Refactor EmployeesController to use AsyncNotifier
class EmployeesNotifier extends AsyncNotifier<List<Employee>> {
  late final EmployeeRepository _repo;

  @override
  Future<List<Employee>> build() async {
    _repo = ref.watch(employeeRepositoryProvider);
    return _repo.getEmployees();
  }

  void load() {
    ref.invalidateSelf();
  }
}

final employeesProvider = AsyncNotifierProvider<EmployeesNotifier, List<Employee>>(
  EmployeesNotifier.new,
);