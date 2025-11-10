import '../../domain/entities/attendance_record.dart';

class AttendanceLocalDataSource {
  final List<AttendanceRecord> _cache = [];

  Future<void> cacheRecords(List<AttendanceRecord> records) async {
    _cache
      ..clear()
      ..addAll(records);
  }

  Future<List<AttendanceRecord>> getCachedRecords() async {
    return _cache;
  }
}