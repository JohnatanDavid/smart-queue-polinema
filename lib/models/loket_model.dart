class LoketModel {
  final String id;
  final String nama;
  final String layananId;
  final String namaLayanan;
  final String? antrianSaatIni;
  final String status;

  LoketModel({
    required this.id,
    required this.nama,
    required this.layananId,
    required this.namaLayanan,
    this.antrianSaatIni,
    required this.status,
  });

  // Convert dari Firebase JSON ke Model
  factory LoketModel.fromJson(Map<String, dynamic> json) {
    return LoketModel(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      layananId: json['layananId'] ?? '',
      namaLayanan: json['namaLayanan'] ?? '',
      antrianSaatIni: json['antrianSaatIni'],
      status: json['status'] ?? 'tersedia',
    );
  }

  // Convert dari Model ke Firebase JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'layananId': layananId,
      'namaLayanan': namaLayanan,
      'antrianSaatIni': antrianSaatIni,
      'status': status,
    };
  }

  // Copy with method untuk update data
  LoketModel copyWith({
    String? id,
    String? nama,
    String? layananId,
    String? namaLayanan,
    String? antrianSaatIni,
    String? status,
  }) {
    return LoketModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      layananId: layananId ?? this.layananId,
      namaLayanan: namaLayanan ?? this.namaLayanan,
      antrianSaatIni: antrianSaatIni ?? this.antrianSaatIni,
      status: status ?? this.status,
    );
  }
}