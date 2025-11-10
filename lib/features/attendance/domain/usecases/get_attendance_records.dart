import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class GetAttendanceRecords {
  final AttendanceRepository repository;
  const GetAttendanceRecords(this.repository);

  Future<List<AttendanceRecord>> call(AttendanceFilters filters) {
    return repository.fetchRecords(filters);
  }
}