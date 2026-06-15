class ProviderModel {
  final int id;
  final String name;
  final String phone;
  final String description;
  final String city;
  final double latitude;
  final double longitude;
  final String? coverImage;
  final int serviceId;
  final String serviceName;

  ProviderModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.description,
    required this.city,
    required this.latitude,
    required this.longitude,
    this.coverImage,
    required this.serviceId,
    required this.serviceName,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      description: json['description'] ?? '',
      city: json['city'],

      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),

      coverImage: json['coverImage'],

      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
    );
  }
}