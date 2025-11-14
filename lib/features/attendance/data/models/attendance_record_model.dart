import '../../domain/entities/attendance_record.dart';

class AttendanceRecordModel extends AttendanceRecord {
  const AttendanceRecordModel({
    required super.id,
    required super.employeeName,
    required super.employeeId,
    required super.department,
    required super.date,
    super.entry,
    super.exit,
    required super.hoursWorked,
    required super.status,
    super.company,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    AttendanceStatus parseStatus(String s) {
      switch (s) {
        case 'punctual':
          return AttendanceStatus.punctual;
        case 'late':
          return AttendanceStatus.late;
        case 'absent':
          return AttendanceStatus.absent;
        case 'vacation':
          return AttendanceStatus.vacation;
        case 'leave':
        default:
          return AttendanceStatus.leave;
      }
    }

    DateTime? parseDateTime(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return AttendanceRecordModel(
      id: json['id']?.toString() ?? '',
      employeeName: json['employeeName'] ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      department: json['department'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      entry: parseDateTime(json['entry']),
      exit: parseDateTime(json['exit']),
      hoursWorked: double.tryParse(json['hoursWorked']?.toString() ?? '0') ?? 0,
      status: parseStatus(json['status'] ?? 'leave'),
      company: json['company']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    String statusToString(AttendanceStatus s) {
      switch (s) {
        case AttendanceStatus.punctual:
          return 'punctual';
        case AttendanceStatus.late:
          return 'late';
        case AttendanceStatus.absent:
          return 'absent';
        case AttendanceStatus.vacation:
          return 'vacation';
        case AttendanceStatus.leave:
          return 'leave';
      }
    }

    return {
      'id': id,
      'employeeName': employeeName,
      'employeeId': employeeId,
      'department': department,
      'date': date.toIso8601String(),
      'entry': entry?.toIso8601String(),
      'exit': exit?.toIso8601String(),
      'hoursWorked': hoursWorked,
      'status': statusToString(status),
      'company': company,
    };
  }
}
