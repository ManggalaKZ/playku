class UserModel {
  final String id;
  final String username;
  final String name;
  final String email;
  final String? password;
  final String? avatar;
  int point;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    this.password,
    this.avatar,
    required this.point,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? "Unknown",
      username: json['username'] ?? "Unknown",
      name: json['name'] ?? "Guest",
      email: json['email'] ?? "",
      password: json['password'],
      avatar: json['avatar'],
      point: json['point'] is int
          ? json['point']
          : int.tryParse(json['point']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'password': password,
      'avatar': avatar,
      'point': point,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? name,
    String? email,
    String? password,
    String? avatar,
    int? point,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
      point: point ?? this.point,
    );
  }
}
