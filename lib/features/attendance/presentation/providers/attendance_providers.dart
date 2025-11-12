import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_intranet/core/providers/dio_provider.dart';

import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/usecases/get_attendance_records.dart';
import '../../data/datasources/attendance_remote_data_source.dart';
import '../../data/datasources/attendance_local_data_source.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/repositories/attendance_repository.dart' show AttendanceFilters; // Import AttendanceFilters from here

// class AttendanceFilters {
//   final DateTimeRange dateRange;
//   final String? department;
//   final String? query;
//   final String? sortBy;
//   final bool ascending;
//   final int page;
//   final int pageSize;

//   const AttendanceFilters({
//     required this.dateRange,
//     this.department,
//     this.query,
//     this.sortBy,
//     this.ascending = true,
//     this.page = 0,
//     this.pageSize = 10,
//   });

//   AttendanceFilters copyWith({
//     DateTimeRange? dateRange,
//     String? department,
//     String? query,
//     String? sortBy,
//     bool? ascending,
//     int? page,
//     int? pageSize,
//   }) {
//     return AttendanceFilters(
//       dateRange: dateRange ?? this.dateRange,
//       department: department ?? this.department,
//       query: query ?? this.query,
//       sortBy: sortBy ?? this.sortBy,
//       ascending: ascending ?? this.ascending,
//       page: page ?? this.page,
//       pageSize: pageSize ?? this.pageSize,
//     );
//   }
// }

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AttendanceRepositoryImpl(
    remote: AttendanceRemoteDataSource(dio),
    local: AttendanceLocalDataSource(),
  );
});

final getAttendanceUseCaseProvider = Provider<GetAttendanceRecords>((ref) {
  final repo = ref.watch(attendanceRepositoryProvider);
  return GetAttendanceRecords(repo);
});

class AttendanceNotifier extends AsyncNotifier<List<AttendanceRecord>> {
  AttendanceFilters _filters = _initialFilters();

  AttendanceFilters get filters => _filters;

  static AttendanceFilters _initialFilters() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: (now.weekday - DateTime.monday) % 7));
    final saturday = DateTime(monday.year, monday.month, monday.day).add(const Duration(days: 5));
    final range = DateTimeRange(start: monday, end: saturday);
    return AttendanceFilters(dateRange: range);
  }

  @override
  Future<List<AttendanceRecord>> build() async {
    return _fetchAttendanceRecords();
  }

  Future<List<AttendanceRecord>> _fetchAttendanceRecords() async {
    final getAttendanceRecords = ref.watch(getAttendanceUseCaseProvider);
    return await getAttendanceRecords.call(_filters);
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAttendanceRecords());
  }

  void setQuery(String query) {
    _filters = _filters.copyWith(query: query, page: 0);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => load());
  }

  void setDepartment(String? dept) {
    _filters = _filters.copyWith(department: dept, page: 0);
    load();
  }

  void setDateRange(DateTimeRange range) {
    final anchor = range.start;
    final monday = anchor.subtract(Duration(days: (anchor.weekday - DateTime.monday) % 7));
    final saturday = DateTime(monday.year, monday.month, monday.day).add(const Duration(days: 5));
    final normalized = DateTimeRange(start: monday, end: saturday);
    _filters = _filters.copyWith(dateRange: normalized, page: 0);
    load();
  }

  void setSort(String by, bool asc) {
    _filters = _filters.copyWith(sortBy: by, ascending: asc);
    load();
  }

  void setPage(int page) {
    _filters = _filters.copyWith(page: page);
    load();
  }

  void previousWeek() {
    final start = _filters.dateRange.start.subtract(const Duration(days: 7));
    final end = _filters.dateRange.end.subtract(const Duration(days: 7));
    setDateRange(DateTimeRange(start: start, end: end));
  }

  void nextWeek() {
    final start = _filters.dateRange.start.add(const Duration(days: 7));
    final end = _filters.dateRange.end.add(const Duration(days: 7));
    setDateRange(DateTimeRange(start: start, end: end));
  }

  Timer? _debounce;
}

final attendanceControllerProvider = AsyncNotifierProvider<AttendanceNotifier, List<AttendanceRecord>>(() {
  return AttendanceNotifier();
});