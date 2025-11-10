import 'package:dio/dio.dart';
import 'package:j_intranet/core/network/endpoints.dart';

import '../models/auth_session_model.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final Dio _dio;
  AuthRemoteDataSource(this._dio);

  Future<AuthSessionModel> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final user = UserModel(id: '1', name: 'Usuario', email: email);
    return AuthSessionModel(token: 'token_placeholder', user: user);
  }

  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  Future<UserModel?> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return null;
  }
}