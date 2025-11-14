import '../../domain/entities/attendance_record.dart';
import 'package:flutter/material.dart';

class AttendanceLocalDataSource {
  final Map<String, List<AttendanceRecord>> _weekCache = {};
  String? _lastKey;

  Future<void> cacheWeek(DateTimeRange range, String? company, List<AttendanceRecord> records) async {
    final key = _key(range, company);
    _weekCache[key] = List<AttendanceRecord>.unmodifiable(records);
    _lastKey = key;
  }

  Future<List<AttendanceRecord>> getCachedWeek(DateTimeRange range, String? company) async {
    final key = _key(range, company);
    return _weekCache[key] ?? const [];
  }

  Future<List<AttendanceRecord>> getLastCached() async {
    if (_lastKey == null) return const [];
    return _weekCache[_lastKey!] ?? const [];
  }

  String _key(DateTimeRange range, String? company) {
    final start = DateTime(range.start.year, range.start.month, range.start.day);
    final end = DateTime(range.end.year, range.end.month, range.end.day);
    return '${company ?? ''}|${start.year}-${start.month}-${start.day}|${end.year}-${end.month}-${end.day}';
  }
}