import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:j_intranet/firebase_options.dart';
import 'dart:io';

void main() async {
  final logFile = File('admin_script_log.txt');
  final sink = logFile.openWrite(mode: FileMode.append);

  try {
    sink.writeln('Initializing Firebase...');
    sink.writeln('Firebase Options: ${DefaultFirebaseOptions.currentPlatform}');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final firestore = FirebaseFirestore.instance;
    final userRef = firestore.collection('users').doc('fHdphyxWx6frF26fVTUhPFI0yRF2');

    await userRef.set({
      'email': 'lacosta@jaysa.com',
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // Add merge option

    sink.writeln('User role updated successfully!');
  } catch (e) {
    sink.writeln('Error: $e');
  } finally {
    await sink.close();
  }
}