class UserModel {
  final String id;
  final String username;
  final String name;
  final String email;
  final String? password;
  final String? avatar;
  int point;
  final List<String>? ownedBorderIds; // Daftar ID border yang dimiliki
  String? usedBorderIds; // Daftar ID border yang dimiliki

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    this.password,
    this.avatar,
    required this.point,
    this.ownedBorderIds, // Jadikan required, tapi bisa diisi list kosong
    this.usedBorderIds, // Jadikan required, tapi bisa diisi list kosong
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Logika parsing untuk ownedBorderIds, default ke list kosong jika null/tidak ada
    List<String> borders = [];
    if (json['ownedBorderIds'] != null && json['ownedBorderIds'] is List) {
      // Pastikan semua elemen dikonversi ke String
      borders = List<String>.from(
          json['ownedBorderIds'].map((item) => item.toString()));
    }

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
      // Assign hasil parsing (bisa jadi list kosong)
      ownedBorderIds: borders,
      usedBorderIds: json['usedBorderIds'] ?? "",
      // Assign hasil parsing (bisa jadi list kosong)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'password':
          password, // Sebaiknya tidak mengirim password kembali ke client
      'avatar': avatar,
      'point': point,
      'ownedBorderIds':
          ownedBorderIds, // Sertakan saat mengirim data (jika perlu)
      'usedBorderIds':
          usedBorderIds, // Sertakan saat mengirim data (jika perlu)
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
    List<String>? ownedBorderIds, // Tambahkan parameter
    String? usedBorderIds, // Tambahkan parameter
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password, // Hati-hati dengan password
      avatar: avatar ?? this.avatar,
      point: point ?? this.point,
      ownedBorderIds: ownedBorderIds ?? this.ownedBorderIds, // Assign nilai
      usedBorderIds: usedBorderIds ?? this.usedBorderIds, // Assign nilai
    );
  }
}
