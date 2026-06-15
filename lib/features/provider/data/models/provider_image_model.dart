class ProviderImageModel {
  final int id;
  final String imageUrl;

  ProviderImageModel({
    required this.id,
    required this.imageUrl,
  });

  factory ProviderImageModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProviderImageModel(
      id: json['id'],
      imageUrl: json['imageUrl'],
    );
  }
}