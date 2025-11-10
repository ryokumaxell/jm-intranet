import '../entities/employee.dart';

abstract class EmployeeRepository {
  Future<List<Employee>> getEmployees();
}