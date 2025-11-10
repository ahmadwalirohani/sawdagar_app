class UserModel {
  final int id;
  final String email;
  final String name;
  final String image;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "name": name,
    "image": image,
  };
}
