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
  final RequestType type;
  final RequestStatus status;

  const Request({
    required this.id,
    required this.type,
    required this.status,
  });
}