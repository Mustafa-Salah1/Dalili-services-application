class ProfileModel {
  final int id;
  final String username;
  final String email;
  final String role;

  ProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
    );
  }
}
