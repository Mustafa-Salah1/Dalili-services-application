class FavoriteModel {
  final int id;
  final int providerId;
  final String providerName;
  final String serviceName;
  final String city;
  final String? coverImage;

  FavoriteModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.serviceName,
    required this.city,
    this.coverImage,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'],
      providerId: json['providerId'],
      providerName: json['providerName'],
      serviceName: json['serviceName'],
      city: json['city'],
      coverImage: json['coverImage'],
    );
  }
}
