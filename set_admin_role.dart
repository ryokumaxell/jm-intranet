import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:j_intranet/firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final userRef = firestore.collection('users').doc('fHdphyxWx6frF26fVTUhPFI0yRF2');

  await userRef.set({
    'email': 'lacosta@jaysa.com',
    'role': 'admin',
    'createdAt': FieldValue.serverTimestamp(),
  });

  print('User role updated successfully!');
}