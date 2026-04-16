class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatar;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['_id'] ?? json['id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'],
        avatar: json['avatarUrl'] ?? json['avatar'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'avatar': avatar,
      };
}
