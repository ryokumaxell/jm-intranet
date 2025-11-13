import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.company,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'employee',
      company: json['company'] ?? '',
    );
  }

  factory UserModel.fromFirestore(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      name: json['displayName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'employee',
      company: json['company'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'company': company,
    };
  }
}
