/// Model representasi data pengguna
class UserModel {
  final int id;
  final String nama;
  final String email;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'created_at': createdAt,
    };
  }
}

