enum RequestType {
  vacation,
  permission,
  tardiness,
  other,
}

enum RequestStatus {
  pending,
  approved,
  rejected,
}

class Request {
  final String id;
  final String employeeId;
  final String employeeName;
  final String employeeEmail;
  final RequestType type;
  final RequestStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final String reason;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  const Request({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    required this.type,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.reason,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
  });
}
