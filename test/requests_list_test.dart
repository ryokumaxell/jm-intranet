import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_intranet/features/requests/presentation/screens/requests_list_screen.dart';

void main() {
  testWidgets('Requests list renders sections with demo items', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: RequestsListScreen())));
    await tester.pumpAndSettle();

    expect(find.text('Solicitudes'), findsOneWidget);
    expect(find.text('Permisos pendientes'), findsOneWidget);
    expect(find.text('Vacaciones'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });
}