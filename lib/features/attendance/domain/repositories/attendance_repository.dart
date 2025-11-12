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

  AttendanceFilters copyWith({
    DateTimeRange? dateRange,
    String? department,
    String? query,
    String? sortBy,
    bool? ascending,
    int? page,
    int? pageSize,
  }) {
    return AttendanceFilters(
      dateRange: dateRange ?? this.dateRange,
      department: department ?? this.department,
      query: query ?? this.query,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

abstract class AttendanceRepository {
  Future<List<AttendanceRecord>> fetchRecords(AttendanceFilters filters);
}