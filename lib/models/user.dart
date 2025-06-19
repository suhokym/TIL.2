class User {
  final int id;
  final String email;
  final String username;
  final String? profileImage;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      profileImage: json['profileImage'],
    );
  }
}
