import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_data_source.dart';
import '../datasources/attendance_local_data_source.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remote;
  final AttendanceLocalDataSource local;

  AttendanceRepositoryImpl({required this.remote, required this.local});

  @override
  Future<List<AttendanceRecord>> fetchRecords(AttendanceFilters filters) async {
    final items = await remote.fetchRecords(
      range: filters.dateRange,
      department: filters.department,
      query: filters.query,
    );
    await local.cacheRecords(items);
    // Sorting
    items.sort((a, b) {
      int cmp;
      switch (filters.sortBy) {
        case 'name':
          cmp = a.employeeName.compareTo(b.employeeName);
          break;
        case 'status':
          cmp = a.status.index.compareTo(b.status.index);
          break;
        case 'date':
        default:
          cmp = a.date.compareTo(b.date);
      }
      return filters.ascending ? cmp : -cmp;
    });
    // Pagination
    final start = filters.page * filters.pageSize;
    final end = (start + filters.pageSize).clamp(0, items.length);
    if (start >= items.length) return const [];
    return items.sublist(start, end);
  }
}