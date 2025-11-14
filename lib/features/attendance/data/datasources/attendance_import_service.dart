import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_record_model.dart';
import '../../domain/entities/attendance_record.dart';

class AttendanceImportService {
  final FirebaseFirestore _firestore;

  AttendanceImportService(this._firestore);

  /// Importa asistencias desde JSON
  /// Formato esperado:
  /// [{"colaborador":"Nombre","asistencias":["lunes, 20 de octubre de 2025 7:27:00 AM",...]}]
  Future<void> importAttendanceFromJson(
      List<dynamic> jsonData, String company) async {
    try {
      final batch = _firestore.batch();

      for (final item in jsonData) {
        final colaborador = item['colaborador'] as String;
        final asistencias = List<String>.from(item['asistencias'] as List);

        // Procesar cada asistencia
        for (final asistenciaStr in asistencias) {
          final record = _parseAttendanceRecord(
            colaborador,
            asistenciaStr,
            company,
          );

          if (record != null) {
            final docRef = _firestore.collection('attendance_records').doc();
            batch.set(docRef, record.toJson());
          }
        }
      }

      await batch.commit();
      print('✅ Asistencias importadas exitosamente');
    } catch (e) {
      print('❌ Error al importar asistencias: $e');
      rethrow;
    }
  }

  /// Parsea una línea de asistencia al formato de AttendanceRecordModel
  AttendanceRecordModel? _parseAttendanceRecord(
    String empleadoNombre,
    String asistenciaStr,
    String company,
  ) {
    try {
      // Parsear fecha: "lunes, 20 de octubre de 2025 7:27:00 AM"
      final dateTime = _parseSpanishDateTime(asistenciaStr);
      if (dateTime == null) return null;

      // Determinar si es entrada o salida basado en la hora
      final isEntry = dateTime.hour < 12; // Mañana = entrada, Tarde = salida

      // Calcular horas trabajadas (placeholder: 8 horas por defecto)
      const hoursWorked = 8.0;

      return AttendanceRecordModel(
        id: '${empleadoNombre}_${dateTime.toIso8601String()}',
        employeeId: empleadoNombre,
        employeeName: empleadoNombre,
        department: 'General',
        company: company,
        date: dateTime,
        entry: isEntry ? dateTime : null,
        exit: !isEntry ? dateTime : null,
        hoursWorked: hoursWorked,
        status: _determineStatus(dateTime, isEntry),
      );
    } catch (e) {
      print('Error parseando asistencia para $empleadoNombre: $e');
      return null;
    }
  }

  /// Parsea fecha en formato español
  /// "lunes, 20 de octubre de 2025 7:27:00 AM"
  DateTime? _parseSpanishDateTime(String dateStr) {
    try {
      // Reemplazar nombres de meses en español
      String normalizedStr = dateStr
          .replaceAll('enero', '01')
          .replaceAll('febrero', '02')
          .replaceAll('marzo', '03')
          .replaceAll('abril', '04')
          .replaceAll('mayo', '05')
          .replaceAll('junio', '06')
          .replaceAll('julio', '07')
          .replaceAll('agosto', '08')
          .replaceAll('septiembre', '09')
          .replaceAll('octubre', '10')
          .replaceAll('noviembre', '11')
          .replaceAll('diciembre', '12')
          // Remover día de la semana
          .replaceAll(RegExp(r'lunes,\s*'), '')
          .replaceAll(RegExp(r'martes,\s*'), '')
          .replaceAll(RegExp(r'miércoles,\s*'), '')
          .replaceAll(RegExp(r'jueves,\s*'), '')
          .replaceAll(RegExp(r'viernes,\s*'), '')
          .replaceAll(RegExp(r'sábado,\s*'), '')
          .replaceAll(RegExp(r'domingo,\s*'), '')
          .replaceAll('de ', '');

      // Parsear: "20 10 2025 7:27:00 AM"
      // Formato: "dd MM yyyy h:mm:ss a"
      final parts = normalizedStr.trim().split(' ');
      if (parts.length < 4) return null;

      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      final timeStr = '${parts[3]} ${parts.length > 4 ? parts[4] : 'AM'}';

      if (day == null || month == null || year == null) return null;

      // Parsear hora
      final timeParts = timeStr.split(':');
      if (timeParts.length < 2) return null;

      var hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      final isPM = timeStr.contains('PM');

      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      print('Error parseando fecha: $dateStr - $e');
      return null;
    }
  }

  /// Determina el estado de asistencia
  AttendanceStatus _determineStatus(DateTime dateTime, bool isEntry) {
    if (!isEntry) return AttendanceStatus.punctual; // Salida = puntual

    // Entrada a las 9:00 AM es la hora esperada
    final scheduledTime =
        DateTime(dateTime.year, dateTime.month, dateTime.day, 9, 0);

    if (dateTime.isBefore(scheduledTime)) {
      return AttendanceStatus.punctual; // Llegó temprano
    } else if (dateTime.difference(scheduledTime).inMinutes > 15) {
      return AttendanceStatus.late; // Más de 15 minutos tarde
    } else {
      return AttendanceStatus.punctual; // Dentro del rango aceptable
    }
  }
}
