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

class AttendanceState {
  final List<AttendanceRecord> records;
  final bool loading;
  final String? error;
  final AttendanceFilters filters;

  const AttendanceState({
    required this.records,
    required this.loading,
    this.error,
    required this.filters,
  });

  AttendanceState copyWith({
    List<AttendanceRecord>? records,
    bool? loading,
    String? error,
    AttendanceFilters? filters,
  }) {
    return AttendanceState(
      records: records ?? this.records,
      loading: loading ?? this.loading,
      error: error,
      filters: filters ?? this.filters,
    );
  }
}

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

class AttendanceController extends StateNotifier<AttendanceState> {
  AttendanceController(this._get) : super(_initialState()) {
    load();
  }

  static AttendanceState _initialState() {
    final now = DateTime.now();
    // Alinear a la semana actual (lunes a sábado)
    final monday = now.subtract(Duration(days: (now.weekday - DateTime.monday) % 7));
    final saturday = DateTime(monday.year, monday.month, monday.day).add(const Duration(days: 5));
    final range = DateTimeRange(start: monday, end: saturday);
    return AttendanceState(
      records: const [],
      loading: false,
      filters: AttendanceFilters(dateRange: range),
    );
  }

  final GetAttendanceRecords _get;
  Timer? _debounce;

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final items = await _get.call(state.filters);
      state = state.copyWith(records: items, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void setQuery(String query) {
    final filters = AttendanceFilters(
      dateRange: state.filters.dateRange,
      department: state.filters.department,
      query: query,
      sortBy: state.filters.sortBy,
      ascending: state.filters.ascending,
      page: 0,
      pageSize: state.filters.pageSize,
    );
    state = state.copyWith(filters: filters);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), load);
  }

  void setDepartment(String? dept) {
    state = state.copyWith(
      filters: AttendanceFilters(
        dateRange: state.filters.dateRange,
        department: dept,
        query: state.filters.query,
        sortBy: state.filters.sortBy,
        ascending: state.filters.ascending,
        page: 0,
        pageSize: state.filters.pageSize,
      ),
    );
  }

  void setDateRange(DateTimeRange range) {
    // Normalizar siempre a lunes-sábado de la semana del rango seleccionado
    final anchor = range.start;
    final monday = anchor.subtract(Duration(days: (anchor.weekday - DateTime.monday) % 7));
    final saturday = DateTime(monday.year, monday.month, monday.day).add(const Duration(days: 5));
    final normalized = DateTimeRange(start: monday, end: saturday);
    state = state.copyWith(
      filters: AttendanceFilters(
        dateRange: normalized,
        department: state.filters.department,
        query: state.filters.query,
        sortBy: state.filters.sortBy,
        ascending: state.filters.ascending,
        page: 0,
        pageSize: state.filters.pageSize,
      ),
    );
  }

  void setSort(String by, bool asc) {
    state = state.copyWith(
      filters: AttendanceFilters(
        dateRange: state.filters.dateRange,
        department: state.filters.department,
        query: state.filters.query,
        sortBy: by,
        ascending: asc,
        page: state.filters.page,
        pageSize: state.filters.pageSize,
      ),
    );
    load();
  }

  void setPage(int page) {
    state = state.copyWith(
      filters: AttendanceFilters(
        dateRange: state.filters.dateRange,
        department: state.filters.department,
        query: state.filters.query,
        sortBy: state.filters.sortBy,
        ascending: state.filters.ascending,
        page: page,
        pageSize: state.filters.pageSize,
      ),
    );
    load();
  }

  // Navegación semanal: mueve el rango una semana hacia atrás
  void previousWeek() {
    final start = state.filters.dateRange.start.subtract(const Duration(days: 7));
    final end = state.filters.dateRange.end.subtract(const Duration(days: 7));
    setDateRange(DateTimeRange(start: start, end: end));
    load();
  }

  // Navegación semanal: mueve el rango una semana hacia adelante
  void nextWeek() {
    final start = state.filters.dateRange.start.add(const Duration(days: 7));
    final end = state.filters.dateRange.end.add(const Duration(days: 7));
    setDateRange(DateTimeRange(start: start, end: end));
    load();
  }
}

final attendanceControllerProvider = StateNotifierProvider<AttendanceController, AttendanceState>((ref) {
  final get = ref.watch(getAttendanceUseCaseProvider);
  return AttendanceController(get);
});