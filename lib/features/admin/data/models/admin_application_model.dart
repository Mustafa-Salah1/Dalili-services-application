class AdminApplicationModel {
  final int id;
  final String phone;
  final String city;
  final String description;
  final String status;
  final int serviceId;
  final String serviceName;
  final int userId;
  final String username;

  AdminApplicationModel({
    required this.id,
    required this.phone,
    required this.city,
    required this.description,
    required this.status,
    required this.serviceId,
    required this.serviceName,
    required this.userId,
    required this.username,
  });

  factory AdminApplicationModel.fromJson(Map<String, dynamic> json) {
    return AdminApplicationModel(
      id: json['id'],
      phone: json['phone'],
      city: json['city'],
      description: json['description'],
      status: json['status'],
      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
      userId: json['userId'],
      username: json['username'],
    );
  }
}
