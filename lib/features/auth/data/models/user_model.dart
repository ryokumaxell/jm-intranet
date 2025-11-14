import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.companies,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final companies = json['companies'];
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'employee',
      companies: companies is List ? List<String>.from(companies) : null,
    );
  }

  factory UserModel.fromFirestore(Map<String, dynamic> json, String id) {
    final companies = json['companies'];
    return UserModel(
      id: id,
      name: json['displayName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'employee',
      companies: companies is List ? List<String>.from(companies) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'companies': companies,
    };
  }
}
