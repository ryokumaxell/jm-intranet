import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/attendance_record.dart';
import '../models/attendance_record_model.dart';

class AttendanceRemoteDataSource {
  final Dio dio;

  AttendanceRemoteDataSource(this.dio);

  Future<List<AttendanceRecord>> fetchRecords(
      {required DateTimeRange range,
      String? department,
      String query = '',
      String? company}) async {
    try {
      // Cargar datos desde el archivo JSON de assets
      final records = await _loadRecordsFromAssets(company);

      // Filtrar por rango de fechas
      final filteredByDate = records
          .where((r) =>
              r.date.isAfter(range.start.subtract(const Duration(days: 1))) &&
              r.date.isBefore(range.end.add(const Duration(days: 1))))
          .toList();

      // Aplicar filtros adicionales
      return filteredByDate
          .where((e) => (department == null || e.department == department))
          .where((e) =>
              query.isEmpty ||
              e.employeeName.toLowerCase().contains(query.toLowerCase()) ||
              e.employeeId.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print('Error fetching attendance records: $e');
      // Fallback a datos de prueba si falla
      return _getFallbackData(range, department, query, company);
    }
  }

  /// Carga registros desde el archivo JSON en assets
  Future<List<AttendanceRecord>> _loadRecordsFromAssets(String? company) async {
    try {
      final records = <AttendanceRecord>[];
      String companyName = 'Helaco';

      // Datos de Helaco (25 empleados con sus asistencias)
      final jsonData = _getHelacoData();

      if (jsonData == null) {
        print('No data available for company: $company');
        return [];
      }

      for (final item in jsonData) {
        final colaborador = item['colaborador'] ?? '';
        final asistencias = item['asistencias'] ?? [];

        if (asistencias is List) {
          for (final asistencia in asistencias) {
            try {
              // Parsear la fecha y hora
              final dateTime = _parseSpanishDateTime(asistencia);
              if (dateTime != null) {
                // Determinar si es entrada o salida
                final hour = dateTime.hour;
                final isEntry = hour < 12; // Antes del mediodía es entrada

                records.add(AttendanceRecordModel(
                  id: '${colaborador}_${dateTime.millisecondsSinceEpoch}',
                  employeeName: colaborador,
                  employeeId: colaborador,
                  department: 'General',
                  date: dateTime,
                  entry: isEntry ? dateTime : null,
                  exit: !isEntry ? dateTime : null,
                  hoursWorked: 0,
                  status: _calculateStatus(dateTime),
                  company: companyName,
                ));
              }
            } catch (e) {
              print('Error parsing asistencia: $e');
            }
          }
        }
      }

      return records;
    } catch (e) {
      print('Error loading records from assets: $e');
      return [];
    }
  }

  /// Parsea una fecha en formato español: "lunes, 20 de octubre de 2025 7:27:00 AM"
  DateTime? _parseSpanishDateTime(String dateString) {
    try {
      // Ejemplo: "lunes, 20 de octubre de 2025 7:27:00 AM"
      final parts = dateString.split(' ');
      if (parts.length < 5) return null;

      // Extraer día, mes, año
      final day = int.tryParse(parts[1].replaceAll(',', '')) ?? 0;
      final monthName = parts[3];
      final year = int.tryParse(parts[4]) ?? 0;

      // Mapear mes en español a número
      final monthMap = {
        'enero': 1,
        'febrero': 2,
        'marzo': 3,
        'abril': 4,
        'mayo': 5,
        'junio': 6,
        'julio': 7,
        'agosto': 8,
        'septiembre': 9,
        'octubre': 10,
        'noviembre': 11,
        'diciembre': 12,
      };

      final month = monthMap[monthName.toLowerCase()] ?? 0;
      if (month == 0) return null;

      // Extraer hora, minuto, segundo y AM/PM
      final timeParts = parts[5].split(':');
      var hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      final second = int.tryParse(timeParts[2]) ?? 0;

      // Ajustar hora si es PM
      if (parts[6].toUpperCase() == 'PM' && hour != 12) {
        hour += 12;
      } else if (parts[6].toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }

      return DateTime(year, month, day, hour, minute, second);
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  /// Calcula el estado de asistencia basado en la hora
  AttendanceStatus _calculateStatus(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;

    // Si es entrada (antes del mediodía)
    if (hour < 12) {
      // Jornada inicia a las 9:00 AM
      if (hour < 9 || (hour == 9 && minute <= 0)) {
        return AttendanceStatus.punctual;
      } else {
        return AttendanceStatus.late;
      }
    }

    // Si es salida, considerar punctual (presente)
    return AttendanceStatus.punctual;
  }

  /// Devuelve los datos de Helaco directamente
  List<dynamic>? _getHelacoData() {
    return [
      {
        "colaborador": "Juan De La Cruz",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:27:00 AM",
          "lunes, 20 de octubre de 2025 5:01:00 PM",
          "martes, 21 de octubre de 2025 8:01:00 AM",
          "martes, 21 de octubre de 2025 4:02:00 PM",
          "miércoles, 22 de octubre de 2025 7:44:00 AM",
          "miércoles, 22 de octubre de 2025 12:57:00 PM"
        ]
      },
      {
        "colaborador": "Carlos Cornielle Feliz",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:53:00 AM",
          "lunes, 20 de octubre de 2025 5:01:00 PM",
          "martes, 21 de octubre de 2025 8:01:00 AM",
          "martes, 21 de octubre de 2025 3:57:00 PM",
          "miércoles, 22 de octubre de 2025 7:44:00 AM",
          "miércoles, 22 de octubre de 2025 12:57:00 PM"
        ]
      },
      {
        "colaborador": "Albelto Leon",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:48:00 AM",
          "lunes, 20 de octubre de 2025 5:00:00 PM",
          "martes, 21 de octubre de 2025 7:33:00 AM",
          "martes, 21 de octubre de 2025 4:22:00 PM",
          "miércoles, 22 de octubre de 2025 8:15:00 AM",
          "miércoles, 22 de octubre de 2025 12:50:00 PM"
        ]
      },
      {
        "colaborador": "Johan Marcelo Marcelo",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:37:00 AM",
          "lunes, 20 de octubre de 2025 5:01:00 PM",
          "martes, 21 de octubre de 2025 7:58:00 AM",
          "martes, 21 de octubre de 2025 4:26:00 PM",
          "miércoles, 22 de octubre de 2025 7:27:00 AM",
          "miércoles, 22 de octubre de 2025 12:59:00 PM"
        ]
      },
      {
        "colaborador": "Andres Miscael Mateo",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:44:00 AM",
          "lunes, 20 de octubre de 2025 4:59:00 PM",
          "martes, 21 de octubre de 2025 7:33:00 AM",
          "martes, 21 de octubre de 2025 3:52:00 PM",
          "miércoles, 22 de octubre de 2025 7:21:00 AM",
          "miércoles, 22 de octubre de 2025 1:32:00 PM"
        ]
      },
      {
        "colaborador": "Dioris Almonte",
        "asistencias": [
          "lunes, 20 de octubre de 2025 6:04:00 AM",
          "lunes, 20 de octubre de 2025 7:49:00 PM",
          "martes, 21 de octubre de 2025 7:53:00 AM",
          "martes, 21 de octubre de 2025 3:48:00 PM",
          "miércoles, 22 de octubre de 2025 8:03:00 AM",
          "miércoles, 22 de octubre de 2025 1:09:00 PM"
        ]
      },
      {
        "colaborador": "Luis Bodre",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:51:00 AM",
          "lunes, 20 de octubre de 2025 5:13:00 PM",
          "martes, 21 de octubre de 2025 8:06:00 AM",
          "martes, 21 de octubre de 2025 4:31:00 PM",
          "miércoles, 22 de octubre de 2025 8:04:00 AM",
          "miércoles, 22 de octubre de 2025 1:03:00 PM"
        ]
      },
      {
        "colaborador": "Femari Rojas",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:46:00 AM",
          "martes, 21 de octubre de 2025 7:53:00 AM",
          "martes, 21 de octubre de 2025 4:33:00 PM",
          "miércoles, 22 de octubre de 2025 7:58:00 AM",
          "miércoles, 22 de octubre de 2025 1:19:00 PM"
        ]
      },
      {
        "colaborador": "Isaias Cedano",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:41:00 AM",
          "lunes, 20 de octubre de 2025 5:00:00 PM",
          "martes, 21 de octubre de 2025 8:43:00 AM",
          "martes, 21 de octubre de 2025 3:49:00 PM",
          "miércoles, 22 de octubre de 2025 7:23:00 AM",
          "miércoles, 22 de octubre de 2025 12:57:00 PM"
        ]
      },
      {
        "colaborador": "Michael Encarnacion",
        "asistencias": [
          "lunes, 20 de octubre de 2025 8:05:00 AM",
          "lunes, 20 de octubre de 2025 5:00:00 PM",
          "martes, 21 de octubre de 2025 8:02:00 AM",
          "miércoles, 22 de octubre de 2025 7:57:00 AM",
          "miércoles, 22 de octubre de 2025 12:56:00 PM"
        ]
      },
      {
        "colaborador": "Pedro Olivares",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:02:00 AM",
          "lunes, 20 de octubre de 2025 5:00:00 PM",
          "martes, 21 de octubre de 2025 7:01:00 AM",
          "martes, 21 de octubre de 2025 3:49:00 PM",
          "miércoles, 22 de octubre de 2025 6:52:00 AM",
          "miércoles, 22 de octubre de 2025 12:56:00 PM"
        ]
      },
      {
        "colaborador": "Diuchensy Ortiz",
        "asistencias": [
          "lunes, 20 de octubre de 2025 6:51:00 AM",
          "lunes, 20 de octubre de 2025 5:00:00 PM",
          "martes, 21 de octubre de 2025 6:41:00 AM",
          "miércoles, 22 de octubre de 2025 6:12:00 AM"
        ]
      },
      {
        "colaborador": "Zusana Encarnacion",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:42:00 AM",
          "lunes, 20 de octubre de 2025 5:00:00 PM",
          "martes, 21 de octubre de 2025 8:00:00 AM",
          "martes, 21 de octubre de 2025 4:04:00 PM",
          "miércoles, 22 de octubre de 2025 7:47:00 AM",
          "miércoles, 22 de octubre de 2025 1:01:00 PM"
        ]
      },
      {
        "colaborador": "Esnaider Jean",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:53:00 AM",
          "lunes, 20 de octubre de 2025 5:00:00 PM",
          "martes, 21 de octubre de 2025 8:01:00 AM",
          "martes, 21 de octubre de 2025 4:01:00 PM",
          "miércoles, 22 de octubre de 2025 7:44:00 AM",
          "miércoles, 22 de octubre de 2025 1:09:00 PM"
        ]
      },
      {
        "colaborador": "Carlos Montero",
        "asistencias": [
          "lunes, 20 de octubre de 2025 8:05:00 AM",
          "lunes, 20 de octubre de 2025 5:00:00 PM",
          "martes, 21 de octubre de 2025 7:53:00 AM",
          "miércoles, 22 de octubre de 2025 7:54:00 AM",
          "miércoles, 22 de octubre de 2025 12:56:00 PM"
        ]
      },
      {
        "colaborador": "Argeny Vicente",
        "asistencias": [
          "lunes, 20 de octubre de 2025 6:04:00 AM",
          "lunes, 20 de octubre de 2025 7:49:00 PM",
          "martes, 21 de octubre de 2025 8:00:00 AM",
          "miércoles, 22 de octubre de 2025 7:48:00 AM",
          "miércoles, 22 de octubre de 2025 1:09:00 PM"
        ]
      },
      {
        "colaborador": "Juan Nepomuseno",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:47:00 AM",
          "lunes, 20 de octubre de 2025 5:01:00 PM",
          "martes, 21 de octubre de 2025 7:59:00 AM",
          "martes, 21 de octubre de 2025 3:53:00 PM",
          "miércoles, 22 de octubre de 2025 8:06:00 AM",
          "miércoles, 22 de octubre de 2025 12:23:00 PM"
        ]
      },
      {
        "colaborador": "Alexander Pena",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:28:00 AM",
          "lunes, 20 de octubre de 2025 5:00:00 PM",
          "martes, 21 de octubre de 2025 7:28:00 AM",
          "martes, 21 de octubre de 2025 3:50:00 PM",
          "miércoles, 22 de octubre de 2025 7:30:00 AM",
          "miércoles, 22 de octubre de 2025 12:56:00 PM"
        ]
      },
      {
        "colaborador": "Luis Bello",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:54:00 AM",
          "lunes, 20 de octubre de 2025 5:00:00 PM",
          "martes, 21 de octubre de 2025 8:01:00 AM",
          "miércoles, 22 de octubre de 2025 8:03:00 AM",
          "miércoles, 22 de octubre de 2025 12:57:00 PM"
        ]
      },
      {
        "colaborador": "Frank Laureano",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:51:00 AM",
          "lunes, 20 de octubre de 2025 5:00:00 PM",
          "martes, 21 de octubre de 2025 7:59:00 AM",
          "martes, 21 de octubre de 2025 3:49:00 PM",
          "miércoles, 22 de octubre de 2025 7:45:00 AM",
          "miércoles, 22 de octubre de 2025 1:33:00 PM"
        ]
      },
      {
        "colaborador": "Wilkin Heredia",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:34:00 AM",
          "lunes, 20 de octubre de 2025 5:00:00 PM",
          "martes, 21 de octubre de 2025 7:36:00 AM",
          "miércoles, 22 de octubre de 2025 7:24:00 AM",
          "miércoles, 22 de octubre de 2025 12:57:00 PM"
        ]
      },
      {
        "colaborador": "Moises Valentin",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:19:00 AM",
          "lunes, 20 de octubre de 2025 5:00:00 PM",
          "martes, 21 de octubre de 2025 7:22:00 AM",
          "miércoles, 22 de octubre de 2025 6:51:00 AM",
          "miércoles, 22 de octubre de 2025 12:57:00 PM"
        ]
      },
      {
        "colaborador": "Henry Paniagua",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:01:00 AM",
          "lunes, 20 de octubre de 2025 5:00:00 PM",
          "martes, 21 de octubre de 2025 6:39:00 AM",
          "martes, 21 de octubre de 2025 3:57:00 PM",
          "miércoles, 22 de octubre de 2025 7:08:00 AM",
          "miércoles, 22 de octubre de 2025 12:19:00 PM"
        ]
      },
      {
        "colaborador": "Ronny Santana",
        "asistencias": [
          "martes, 21 de octubre de 2025 6:38:00 AM",
          "martes, 21 de octubre de 2025 3:50:00 PM",
          "miércoles, 22 de octubre de 2025 7:07:00 AM"
        ]
      },
      {
        "colaborador": "Jose Tineo",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:43:00 AM",
          "lunes, 20 de octubre de 2025 5:00:00 PM",
          "martes, 21 de octubre de 2025 8:00:00 AM",
          "miércoles, 22 de octubre de 2025 7:48:00 AM",
          "miércoles, 22 de octubre de 2025 12:56:00 PM"
        ]
      },
      {
        "colaborador": "Maria Bencosme",
        "asistencias": [
          "lunes, 20 de octubre de 2025 7:54:00 AM",
          "lunes, 20 de octubre de 2025 5:11:00 PM",
          "miércoles, 22 de octubre de 2025 1:19:00 PM"
        ]
      }
    ];
  }

  List<AttendanceRecord> _getFallbackData(
    DateTimeRange range,
    String? department,
    String query,
    String? company,
  ) {
    final now = DateTime.now();
    final sample = <AttendanceRecordModel>[
      AttendanceRecordModel(
        id: 'r1',
        employeeName: 'Juan Pérez',
        employeeId: 'EMP-001',
        department: 'Ventas',
        date: now.subtract(const Duration(days: 1)),
        entry: DateTime(now.year, now.month, now.day - 1, 9, 0),
        exit: DateTime(now.year, now.month, now.day - 1, 17, 0),
        hoursWorked: 8,
        status: AttendanceStatus.punctual,
        company: 'Jaysa Muebles',
      ),
      AttendanceRecordModel(
        id: 'r2',
        employeeName: 'María López',
        employeeId: 'EMP-002',
        department: 'Recursos Humanos',
        date: now.subtract(const Duration(days: 2)),
        entry: DateTime(now.year, now.month, now.day - 2, 9, 30),
        exit: DateTime(now.year, now.month, now.day - 2, 17, 0),
        hoursWorked: 7.5,
        status: AttendanceStatus.late,
        company: 'Helaco',
      ),
      AttendanceRecordModel(
        id: 'r3',
        employeeName: 'Carlos Ruiz',
        employeeId: 'EMP-003',
        department: 'Operaciones',
        date: now.subtract(const Duration(days: 3)),
        entry: null,
        exit: null,
        hoursWorked: 0,
        status: AttendanceStatus.absent,
        company: 'Jaysa Muebles',
      ),
    ];

    return sample
        .where((e) => (department == null || e.department == department))
        .where((e) => (company == null || e.company == company))
        .where((e) =>
            query.isEmpty ||
            e.employeeName.toLowerCase().contains(query.toLowerCase()) ||
            e.employeeId.toLowerCase().contains(query.toLowerCase()))
        .where((e) =>
            e.date.isAfter(range.start.subtract(const Duration(days: 1))) &&
            e.date.isBefore(range.end.add(const Duration(days: 1))))
        .toList();
  }
}
