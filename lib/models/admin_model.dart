class AdminModel {
  final String id;
  final String email;
  final String nama;
  final String loketId;
  final String role;

  AdminModel({
    required this.id,
    required this.email,
    required this.nama,
    required this.loketId,
    required this.role,
  });

  // Convert dari Firebase JSON ke Model
  factory AdminModel.fromJson(String id, Map<String, dynamic> json) {
    return AdminModel(
      id: id,
      email: json['email'] ?? '',
      nama: json['nama'] ?? '',
      loketId: json['loketId'] ?? '',
      role: json['role'] ?? 'admin',
    );
  }

  // Convert dari Model ke Firebase JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nama': nama,
      'loketId': loketId,
      'role': role,
    };
  }

  // Copy with method untuk update data
  AdminModel copyWith({
    String? id,
    String? email,
    String? nama,
    String? loketId,
    String? role,
  }) {
    return AdminModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      loketId: loketId ?? this.loketId,
      role: role ?? this.role,
    );
  }
}