import 'package:flutter/material.dart';
import '../../domain/entities/request.dart';

class RequestCard extends StatelessWidget {
  final Request request;
  const RequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('${request.type} • ${request.status}'),
        subtitle: Text('ID: ${request.id}'),
      ),
    );
  }
}