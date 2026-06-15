class ServiceModel {
  final int id;
  final String title;
  final String description;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }
}
