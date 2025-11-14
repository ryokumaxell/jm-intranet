import '../../domain/entities/request.dart';

class RequestModel extends Request {
  const RequestModel({
    required super.id,
    required super.employeeId,
    required super.employeeName,
    required super.employeeEmail,
    required super.type,
    required super.status,
    required super.startDate,
    super.endDate,
    required super.reason,
    required super.createdAt,
    super.approvedAt,
    super.approvedBy,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type']?.toString() ?? 'other';
    final statusStr = json['status']?.toString() ?? 'pending';
    return RequestModel(
      id: json['id']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      employeeName: json['employeeName']?.toString() ?? '',
      employeeEmail: json['employeeEmail']?.toString() ?? '',
      type: RequestType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => RequestType.other,
      ),
      status: RequestStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => RequestStatus.pending,
      ),
      startDate: json['startDate'] is DateTime
          ? json['startDate']
          : DateTime.tryParse(json['startDate']?.toString() ?? '') ??
              DateTime.now(),
      endDate: json['endDate'] != null
          ? (json['endDate'] is DateTime
              ? json['endDate']
              : DateTime.tryParse(json['endDate']?.toString() ?? ''))
          : null,
      reason: json['reason']?.toString() ?? '',
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt']
          : DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
      approvedAt: json['approvedAt'] != null
          ? (json['approvedAt'] is DateTime
              ? json['approvedAt']
              : DateTime.tryParse(json['approvedAt']?.toString() ?? ''))
          : null,
      approvedBy: json['approvedBy']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'employeeEmail': employeeEmail,
      'type': type.name,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'approvedBy': approvedBy,
    };
  }
}
