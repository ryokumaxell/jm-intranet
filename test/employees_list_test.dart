import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:j_intranet/features/employees/presentation/screens/employees_list_screen.dart';

void main() {
  testWidgets('Employees list renders and groups by company', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: EmployeesListScreen())));
    await tester.pumpAndSettle();

    expect(find.text('Empleados'), findsOneWidget);
    expect(find.text('Jaysa Muebles'), findsOneWidget);
    expect(find.text('Helaco'), findsOneWidget);
    expect(find.text('Juan Pérez'), findsOneWidget);
    expect(find.text('Carlos Ruiz'), findsOneWidget);
  });
}