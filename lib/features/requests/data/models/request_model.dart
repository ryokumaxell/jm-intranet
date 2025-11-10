import '../../domain/entities/request.dart';

class RequestModel extends Request {
  const RequestModel({
    required super.id,
    required super.type,
    required super.status,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'status': status,
    };
  }
}