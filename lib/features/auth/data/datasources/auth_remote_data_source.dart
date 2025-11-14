import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/auth_session_model.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource(Dio dio)
      : _firebaseAuth = firebase_auth.FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance;

  Future<AuthSessionModel> login(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    final user = await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();
    final userModel = UserModel.fromFirestore(user.data()!, user.id);
    final token = await userCredential.user!.getIdToken();
    if (token == null) {
      throw Exception('Authentication token is null');
    }
    return AuthSessionModel(token: token, user: userModel);
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return null;
    }
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return UserModel.fromFirestore(userDoc.data()!, user.uid);
  }

  Future<UserModel> createUser(
      {required String email,
      required String password,
      required String role,
      required List<String> companies}) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    final userUid = userCredential.user!.uid;
    await _firestore.collection('users').doc(userUid).set({
      'email': email,
      'role': role,
      'companies': companies,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final userDoc = await _firestore.collection('users').doc(userUid).get();
    return UserModel.fromFirestore(userDoc.data()!, userUid);
  }
}
