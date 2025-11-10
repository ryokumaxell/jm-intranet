import 'package:flutter/material.dart';

class RequestDetailScreen extends StatelessWidget {
  final String id;
  const RequestDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: Center(
        child: Text('Solicitud $id'),
      ),
    );
  }
}