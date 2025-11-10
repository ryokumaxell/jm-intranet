import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/metric.dart';
import '../../domain/entities/activity.dart';

final dashboardMetricsProvider = Provider<List<Metric>>((ref) {
  return const [
    Metric(key: 'requests', title: 'Solicitudes', value: '128', subtitle: '+8 esta semana'),
    Metric(key: 'approved', title: 'Aprobadas', value: '76', subtitle: '+3 hoy'),
    Metric(key: 'pending', title: 'Pendientes', value: '42', subtitle: 'Revisión requerida'),
    Metric(key: 'rejected', title: 'Rechazadas', value: '10', subtitle: '—'),
  ];
});

final recentActivitiesProvider = Provider<List<Activity>>((ref) {
  final now = DateTime.now();
  return [
    Activity(
      id: 'a1',
      title: 'Nueva solicitud de vacaciones',
      description: 'Juan Pérez solicitó 3 días de vacaciones',
      timestamp: now.subtract(const Duration(hours: 2)),
      type: 'info',
    ),
    Activity(
      id: 'a2',
      title: 'Solicitud aprobada',
      description: 'Aprobación de permiso médico',
      timestamp: now.subtract(const Duration(hours: 5)),
      type: 'success',
    ),
    Activity(
      id: 'a3',
      title: 'Solicitud rechazada',
      description: 'Rechazo por falta de documentación',
      timestamp: now.subtract(const Duration(days: 1)),
      type: 'danger',
    ),
  ];
});