class RequestModel {
  final int id;
  final int userId;
  final String username;
  final int providerId;
  final String providerName;

  final String requestDate;
  final String requestTime;

  final int estimatedDurationMinutes;

  final String notes;
  final String status;
  final String createdAt;

  RequestModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.providerId,
    required this.providerName,
    required this.requestDate,
    required this.requestTime,
    required this.estimatedDurationMinutes,
    required this.notes,
    required this.status,
    required this.createdAt,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      providerId: json['providerId'],
      providerName: json['providerName'],

      requestDate: json['requestDate'],
      requestTime: json['requestTime'],

      estimatedDurationMinutes: json['estimatedDurationMinutes'] ?? 0,

      notes: json['notes'] ?? '',
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }
}
