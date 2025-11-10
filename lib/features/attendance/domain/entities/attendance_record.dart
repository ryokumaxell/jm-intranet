enum AttendanceStatus { punctual, late, absent, vacation, leave }

class AttendanceRecord {
  final String id;
  final String employeeName;
  final String employeeId;
  final String department;
  final DateTime date;
  final DateTime? entry;
  final DateTime? exit;
  final double hoursWorked;
  final AttendanceStatus status;

  const AttendanceRecord({
    required this.id,
    required this.employeeName,
    required this.employeeId,
    required this.department,
    required this.date,
    this.entry,
    this.exit,
    required this.hoursWorked,
    required this.status,
  });
}