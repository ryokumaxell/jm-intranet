import '../../domain/entities/auth_session.dart';
import 'user_model.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.token,
    required super.user,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      token: json['token'] ?? '',
      user: UserModel.fromJson(json['user'] ?? <String, dynamic>{}),
    );
  }

  Map<String, dynamic> toJson() {
    final userJson = user is UserModel
        ? (user as UserModel).toJson()
        : {
            'id': user.id,
            'name': user.name,
            'email': user.email,
          };
    return {
      'token': token,
      'user': userJson,
    };
  }
}