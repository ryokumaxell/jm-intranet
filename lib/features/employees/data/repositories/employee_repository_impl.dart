import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employees_remote_data_source.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeesRemoteDataSource remote;
  EmployeeRepositoryImpl(this.remote);

  @override
  Future<List<Employee>> getEmployees() {
    return remote.getEmployees();
  }
}