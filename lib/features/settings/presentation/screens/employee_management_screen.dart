import 'package:j_intranet/features/settings/presentation/widgets/manual_add_employee.dart';
import 'package:j_intranet/features/settings/presentation/widgets/batch_add_employees.dart';
import 'package:flutter/material.dart';

class EmployeeManagementScreen extends StatelessWidget {
  const EmployeeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestión de Empleados'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'MANUAL'),
              Tab(text: 'POR LOTE'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const ManualAddEmployee(),
            
            const BatchAddEmployees(),
          ],
        ),
      ),
    );
  }
}