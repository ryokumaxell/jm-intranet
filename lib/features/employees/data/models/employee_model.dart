import '../../domain/entities/employee.dart';

class EmployeeModel extends Employee {
  const EmployeeModel({
    required super.id,
    required super.name,
    required super.department,
    required super.company,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      department: json['department'] ?? '',
      company: json['company'] ?? 'Jaysa Muebles',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'department': department,
        'company': company,
      };
}