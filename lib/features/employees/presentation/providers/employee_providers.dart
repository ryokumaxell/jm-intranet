import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_intranet/core/providers/dio_provider.dart';

import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../../data/datasources/employees_remote_data_source.dart';
import '../../data/repositories/employee_repository_impl.dart';

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final ds = EmployeesRemoteDataSource(dio);
  return EmployeeRepositoryImpl(ds);
});

class EmployeesController extends StateNotifier<List<Employee>> {
  EmployeesController(this._repo) : super(const []);
  final EmployeeRepository _repo;

  Future<void> load() async {
    final items = await _repo.getEmployees();
    state = items;
  }
}

final employeesProvider = StateNotifierProvider<EmployeesController, List<Employee>>((ref) {
  final repo = ref.watch(employeeRepositoryProvider);
  return EmployeesController(repo);
});