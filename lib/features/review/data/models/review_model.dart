class ReviewModel {
  final int id;
  final int rating;
  final String comment;
  final int providerId;
  final String providerName;
  final int userId;
  final String username;

  ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.providerId,
    required this.providerName,
    required this.userId,
    required this.username,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      rating: json['rating'],
      comment: json['comment'],
      providerId: json['providerId'],
      providerName: json['providerName'],
      userId: json['userId'],
      username: json['username'],
    );
  }
}
