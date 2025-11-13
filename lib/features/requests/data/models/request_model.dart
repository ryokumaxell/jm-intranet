import '../../domain/entities/request.dart';

class RequestModel extends Request {
  const RequestModel({
    required super.id,
    required super.type,
    required super.status,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type']?.toString() ?? 'other';
    final statusStr = json['status']?.toString() ?? 'pending';
    return RequestModel(
      id: json['id']?.toString() ?? '',
      type: RequestType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => RequestType.other,
      ),
      status: RequestStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => RequestStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'status': status.name,
    };
  }
}