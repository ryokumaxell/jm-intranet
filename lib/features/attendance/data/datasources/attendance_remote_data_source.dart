import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../domain/entities/attendance_record.dart';
import '../models/attendance_record_model.dart';

class AttendanceRemoteDataSource {
  final Dio dio;
  final Map<String, List<AttendanceRecord>> _weekCache = {};

  AttendanceRemoteDataSource(this.dio);

  Future<List<AttendanceRecord>> fetchRecords(
      {required DateTimeRange range,
      String? department,
      String query = '',
      String? company}) async {
    try {
      final companyName = company ?? 'Helaco';
      final start = DateTime(range.start.year, range.start.month, range.start.day);
      final end = DateTime(range.end.year, range.end.month, range.end.day);
      final cacheKey = '$companyName|${start.year}-${start.month}-${start.day}|${end.year}-${end.month}-${end.day}';

      List<AttendanceRecord> records = _weekCache[cacheKey] ?? const [];
      if (records.isEmpty) {
        records = await _loadWeekRecordsFromAssets(range, companyName);
        _weekCache[cacheKey] = records;
      }

      // Filtrar por rango de fechas
      final filteredByDate = records
          .where((r) =>
              r.date.isAfter(range.start.subtract(const Duration(days: 1))) &&
              r.date.isBefore(range.end.add(const Duration(days: 1))))
          .toList();

      // Combinar múltiples marcas de un mismo colaborador en un día
      final merged = _mergeRecordsByEmployeeAndDay(filteredByDate);

      // Aplicar filtros adicionales
      return merged
          .where((e) => (department == null || e.department == department))
          .where((e) =>
              query.isEmpty ||
              e.employeeName.toLowerCase().contains(query.toLowerCase()) ||
              e.employeeId.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching attendance records: $e');
      // Fallback a datos de prueba si falla
      return _getFallbackData(range, department, query, company);
    }
  }

  Future<List<AttendanceRecord>> _loadWeekRecordsFromAssets(
    DateTimeRange range,
    String companyName,
  ) async {
    final employeeRecords = <String, Map<DateTime, AttendanceRecordModel>>{};

    try {
      final s = DateTime(range.start.year, range.start.month, range.start.day);
      final e = DateTime(range.end.year, range.end.month, range.end.day);
      String pad(int v) => v.toString().padLeft(2, '0');
      final startStr = '${pad(s.day)}-${pad(s.month)}-${(s.year % 100).toString().padLeft(2, '0')}';
      final endStr = '${pad(e.day)}-${pad(e.month)}-${(e.year % 100).toString().padLeft(2, '0')}';
      final companyKey = companyName == 'Jaysa Muebles' ? 'jaysamuebles' : 'helaco';

      final candidates = <String>[
        'assets/data/asis_${companyKey}_${startStr} a ${endStr}.json',
        'assets/data/asis_${companyKey}_${startStr}a${endStr}.json',
      ];

      String? existingPath;
      for (final p in candidates) {
        try {
          await rootBundle.load(p);
          existingPath = p;
          break;
        } catch (_) {}
      }

      if (existingPath == null) {
        debugPrint('No se encontró archivo para $companyName semana $startStr a $endStr');
        return const [];
      }

      final byteData = await rootBundle.load(existingPath);
      final bytes = byteData.buffer.asUint8List();

      String jsonString;
      try {
        jsonString = utf8.decode(bytes);
      } on FormatException {
        var startIndex = 0;
        if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
          startIndex = 2;
        }
        final codeUnits = <int>[];
        for (var i = startIndex; i + 1 < bytes.length; i += 2) {
          final unit = bytes[i] | (bytes[i + 1] << 8);
          codeUnits.add(unit);
        }
        jsonString = String.fromCharCodes(codeUnits);
      }

      final data = jsonDecode(jsonString);
      if (data is List) {
        for (final item in data) {
          if (item is! Map) continue;
          final colaborador = item['colaborador'] as String? ?? '';
          final asistencias = item['asistencias'] as List<dynamic>? ?? const [];
          if (colaborador.isEmpty || asistencias.isEmpty) continue;

          final employeeDays = employeeRecords.putIfAbsent(colaborador, () => {});

          for (final raw in asistencias) {
            if (raw is! String) continue;
            final dateTime = _parseSpanishDateTime(raw);
            if (dateTime == null) continue;

            final day = DateTime(dateTime.year, dateTime.month, dateTime.day);
            final isEntry = dateTime.hour < 12;

            final existing = employeeDays[day];
            if (existing == null) {
              employeeDays[day] = AttendanceRecordModel(
                id: '${colaborador}_${day.millisecondsSinceEpoch}',
                employeeName: colaborador,
                employeeId: colaborador,
                department: 'General',
                date: day,
                entry: isEntry ? dateTime : null,
                exit: !isEntry ? dateTime : null,
                hoursWorked: 8.0,
                status: isEntry ? _calculateStatus(dateTime) : AttendanceStatus.punctual,
                company: companyName,
              );
            } else {
              if (isEntry) {
                employeeDays[day] = AttendanceRecordModel(
                  id: existing.id,
                  employeeName: existing.employeeName,
                  employeeId: existing.employeeId,
                  department: existing.department,
                  date: existing.date,
                  entry: dateTime,
                  exit: existing.exit,
                  hoursWorked: existing.hoursWorked,
                  status: _calculateStatus(dateTime),
                  company: existing.company,
                );
              } else {
                employeeDays[day] = AttendanceRecordModel(
                  id: existing.id,
                  employeeName: existing.employeeName,
                  employeeId: existing.employeeId,
                  department: existing.department,
                  date: existing.date,
                  entry: existing.entry,
                  exit: dateTime,
                  hoursWorked: existing.hoursWorked,
                  status: existing.status,
                  company: existing.company,
                );
              }
            }
          }
        }
      }

      final allRecords = <AttendanceRecord>[];
      for (final employee in employeeRecords.values) {
        allRecords.addAll(employee.values);
      }
      debugPrint('✅ Cargados ${allRecords.length} registros para $companyName ($existingPath)');
      return allRecords;
    } catch (e) {
      debugPrint('Error loading week from assets: $e');
      return [];
    }
  }

  /// Carga registros desde el archivo JSON en assets
  Future<List<AttendanceRecord>> _loadRecordsFromAssets(String? company) async {
    final employeeRecords = <String, Map<DateTime, AttendanceRecordModel>>{};

    try {
      final companyName = company ?? 'Helaco';

      // Seleccionar archivos según la compañía
      final files = companyName == 'Jaysa Muebles'
          ? <String>[
              'assets/data/asis_jaysamuebles_01a06-09-25.json',
              'assets/data/asis_jaysamuebles_02a07-06-25.json',
              'assets/data/asis_jaysamuebles_03-11-25 a 08-11-25.json',
              'assets/data/asis_jaysamuebles_04a09-08-25.json',
              'assets/data/asis_jaysamuebles_06-10-25 a 11-10-25.json',
              'assets/data/asis_jaysamuebles_07a12-07-25.json',
              'assets/data/asis_jaysamuebles_08a13-09-25.json',
              'assets/data/asis_jaysamuebles_09a14-06-25.json',
              'assets/data/asis_jaysamuebles_11a16-08-25.json',
              'assets/data/asis_jaysamuebles_12a17-05-25.json',
              'assets/data/asis_jaysamuebles_13-10-25 a 18-10-25.json',
              'assets/data/asis_jaysamuebles_14a19-07-25.json',
              'assets/data/asis_jaysamuebles_15a20-09-25.json',
              'assets/data/asis_jaysamuebles_16a21-06-25.json',
              'assets/data/asis_jaysamuebles_18a23-08-25.json',
              'assets/data/asis_jaysamuebles_19a24-05-25.json',
              'assets/data/asis_jaysamuebles_20-10-25 a 25-10-25.json',
              'assets/data/asis_jaysamuebles_21a26-07-25.json',
              'assets/data/asis_jaysamuebles_22a27-09-25.json',
              'assets/data/asis_jaysamuebles_23a28-06-25.json',
              'assets/data/asis_jaysamuebles_25a30-08-25.json',
              'assets/data/asis_jaysamuebles_26a31-05-25.json',
              'assets/data/asis_jaysamuebles_27-10-25 a 01-11-25.json',
              'assets/data/asis_jaysamuebles_28-07a02-08-25.json',
              'assets/data/asis_jaysamuebles_29-09-25 a 04-10-25.json',
              'assets/data/asis_jaysamuebles_30-06a04-07-25.json',
            ]
          : <String>[
              'assets/data/asis_helaco_01a06-09-25.json',
              'assets/data/asis_helaco_02a07-06-25.json',
              'assets/data/asis_helaco_03-11-25 a 08-11-25.json',
              'assets/data/asis_helaco_04a09-08-25.json',
              'assets/data/asis_helaco_06-10-25 a 11-10-25.json',
              'assets/data/asis_helaco_07a12-07-25.json',
              'assets/data/asis_helaco_08a13-09-25.json',
              'assets/data/asis_helaco_09a14-06-25.json',
              'assets/data/asis_helaco_11a16-08-25.json',
              'assets/data/asis_helaco_12a17-05-25.json',
              'assets/data/asis_helaco_13-10-25 a 18-10-25.json',
              'assets/data/asis_helaco_14a19-07-25.json',
              'assets/data/asis_helaco_15a20-09-25.json',
              'assets/data/asis_helaco_16a21-06-25.json',
              'assets/data/asis_helaco_18a23-08-25.json',
              'assets/data/asis_helaco_19a24-05-25.json',
              'assets/data/asis_helaco_20-10-25 a 25-10-25.json',
              'assets/data/asis_helaco_20-10-25a25-10-25.json',
              'assets/data/asis_helaco_21a26-07-25.json',
              'assets/data/asis_helaco_22a27-09-25.json',
              'assets/data/asis_helaco_23a28-06-25.json',
              'assets/data/asis_helaco_25a30-08-25.json',
              'assets/data/asis_helaco_26a31-05-25.json',
              'assets/data/asis_helaco_27-10-25 a 01-11-25.json',
              'assets/data/asis_helaco_28-07a02-08-25.json',
              'assets/data/asis_helaco_29-09-25 a 04-10-25.json',
              'assets/data/asis_helaco_30-06a04-07-25.json',
            ];

      for (final path in files) {
        try {
          final byteData = await rootBundle.load(path);
          final bytes = byteData.buffer.asUint8List();

          String jsonString;
          try {
            jsonString = utf8.decode(bytes);
          } on FormatException {
            var startIndex = 0;
            if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
              startIndex = 2;
            }

            final codeUnits = <int>[];
            for (var i = startIndex; i + 1 < bytes.length; i += 2) {
              final unit = bytes[i] | (bytes[i + 1] << 8);
              codeUnits.add(unit);
            }
            jsonString = String.fromCharCodes(codeUnits);
          }

          final data = jsonDecode(jsonString);
          if (data is! List) continue;

          for (final item in data) {
            if (item is! Map) continue;
            final colaborador = item['colaborador'] as String? ?? '';
            final asistencias = item['asistencias'] as List<dynamic>? ?? const [];
            if (colaborador.isEmpty || asistencias.isEmpty) continue;

            // Initialize employee record if not exists
            if (!employeeRecords.containsKey(colaborador)) {
              employeeRecords[colaborador] = {};
            }
            final employeeDays = employeeRecords[colaborador]!;

            // Process each attendance record
            for (final raw in asistencias) {
              if (raw is! String) continue;
              final dateTime = _parseSpanishDateTime(raw);
              if (dateTime == null) continue;

              // Get the day (date without time)
              final day = DateTime(dateTime.year, dateTime.month, dateTime.day);
              final isEntry = dateTime.hour < 12;

              // If we don't have a record for this day, create one
              if (!employeeDays.containsKey(day)) {
                employeeDays[day] = AttendanceRecordModel(
                  id: '${colaborador}_${day.millisecondsSinceEpoch}',
                  employeeName: colaborador,
                  employeeId: colaborador,
                  department: 'General',
                  date: day,
                  entry: isEntry ? dateTime : null,
                  exit: !isEntry ? dateTime : null,
                  hoursWorked: 8.0,
                  status: isEntry ? _calculateStatus(dateTime) : AttendanceStatus.punctual,
                  company: companyName,
                );
              } else {
                // Update existing record with entry or exit time
                final existing = employeeDays[day]!;
                if (isEntry) {
                  employeeDays[day] = AttendanceRecordModel(
                    id: existing.id,
                    employeeName: existing.employeeName,
                    employeeId: existing.employeeId,
                    department: existing.department,
                    date: existing.date,
                    entry: dateTime,
                    exit: existing.exit,
                    hoursWorked: existing.hoursWorked,
                    status: _calculateStatus(dateTime),
                    company: existing.company,
                  );
                } else {
                  employeeDays[day] = AttendanceRecordModel(
                    id: existing.id,
                    employeeName: existing.employeeName,
                    employeeId: existing.employeeId,
                    department: existing.department,
                    date: existing.date,
                    entry: existing.entry,
                    exit: dateTime,
                    hoursWorked: existing.hoursWorked,
                    status: existing.status,
                    company: existing.company,
                  );
                }
            }
          }
        }
        } catch (e) {
          debugPrint('Error leyendo $path: $e');
        }
      }

      // Flatten the employee records map into a single list
      final allRecords = <AttendanceRecord>[];
      for (final employee in employeeRecords.values) {
        allRecords.addAll(employee.values);
      }

      debugPrint('✅ Cargados ${allRecords.length} registros para $companyName');
      return allRecords;
    } catch (e) {
      debugPrint('Error loading records from assets: $e');
      return [];
    }
  }

  List<AttendanceRecord> _mergeRecordsByEmployeeAndDay(
    List<AttendanceRecord> items,
  ) {
    final map = <String, Map<DateTime, AttendanceRecordModel>>{};

    for (final r in items) {
      final key = r.employeeId.isNotEmpty ? r.employeeId : r.employeeName;
      final day = DateTime(r.date.year, r.date.month, r.date.day);
      final byDay =
          map.putIfAbsent(key, () => <DateTime, AttendanceRecordModel>{});
      final current = byDay[day];

      if (current == null) {
        byDay[day] = AttendanceRecordModel(
          id: r.id,
          employeeName: r.employeeName,
          employeeId: r.employeeId,
          department: r.department,
          date: day,
          entry: r.entry,
          exit: r.exit,
          hoursWorked: r.hoursWorked,
          status: r.status,
          company: r.company,
        );
        continue;
      }

      DateTime? entry = current.entry;
      DateTime? exit = current.exit;

      if (r.entry != null) {
        if (entry == null || r.entry!.isBefore(entry)) {
          entry = r.entry;
        }
      }
      if (r.exit != null) {
        if (exit == null || r.exit!.isAfter(exit)) {
          exit = r.exit;
        }
      }

      final status = entry != null ? _calculateStatus(entry) : current.status;

      byDay[day] = AttendanceRecordModel(
        id: current.id,
        employeeName: current.employeeName,
        employeeId: current.employeeId,
        department: current.department,
        date: day,
        entry: entry,
        exit: exit,
        hoursWorked: current.hoursWorked,
        status: status,
        company: current.company,
      );
    }

    final result = <AttendanceRecord>[];
    for (final byDay in map.values) {
      result.addAll(byDay.values);
    }
    return result;
  }

  /// Parsea una fecha en formato español: "lunes, 20 de octubre de 2025 7:27:00 AM"
  DateTime? _parseSpanishDateTime(String dateStr) {
    try {
      // Paso 1: Remover día de la semana (todo antes de la primera coma)
      final commaIndex = dateStr.indexOf(',');
      if (commaIndex == -1) return null;

      String cleaned = dateStr.substring(commaIndex + 1).trim();

      // Paso 2: Reemplazar nombres de meses en español por números
      cleaned = cleaned
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
          .replaceAll('diciembre', '12');

      // Paso 3: Remover "de " para normalizar
      cleaned = cleaned.replaceAll(' de ', ' ');

      // Ahora debería ser: "20 10 2025 7:27:00 AM"
      final parts = cleaned.trim().split(RegExp(r'\s+'));

      if (parts.length < 5) {
        return null;
      }

      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      final timeStr = parts[3]; // "7:27:00"
      final ampm = parts[4]; // "AM" o "PM"

      if (day == null || month == null || year == null) {
        return null;
      }

      // Parsear hora
      final timeParts = timeStr.split(':');
      if (timeParts.length < 2) {
        return null;
      }

      var hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;

      // Ajustar para formato 24 horas
      if (ampm.toUpperCase() == 'PM' && hour != 12) {
        hour += 12;
      } else if (ampm.toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      debugPrint('Error parsing date: $dateStr - $e');
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
