import 'package:flutter/material.dart';
import '../entities/attendance_record.dart';

class AttendanceFilters {
  final DateTimeRange dateRange;
  final String? department;
  final String query;
  final String sortBy; // 'name' | 'date' | 'status'
  final bool ascending;
  final int page;
  final int pageSize;

  const AttendanceFilters({
    required this.dateRange,
    this.department,
    this.query = '',
    this.sortBy = 'date',
    this.ascending = false,
    this.page = 0,
    this.pageSize = 10,
  });
}

abstract class AttendanceRepository {
  Future<List<AttendanceRecord>> fetchRecords(AttendanceFilters filters);
}