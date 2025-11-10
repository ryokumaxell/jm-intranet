import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/request_providers.dart';
import 'request_detail_screen.dart';
import '../../domain/entities/request.dart';

class RequestsListScreen extends ConsumerWidget {
  const RequestsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(requestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes')),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          return ListTile(
            title: Text('${req.type} • ${req.status}'),
            subtitle: Text('ID: ${req.id}'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RequestDetailScreen(id: req.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ref.read(requestsProvider.notifier).add('vacation');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}