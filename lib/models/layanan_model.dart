class LayananModel {
  final String id;
  final String nama;
  final String kode;
  final String jamBuka;
  final String jamTutup;
  final int estimasiPerPasien;
  final bool aktif;

  LayananModel({
    required this.id,
    required this.nama,
    required this.kode,
    required this.jamBuka,
    required this.jamTutup,
    required this.estimasiPerPasien,
    required this.aktif,
  });

  // Convert dari Firebase JSON ke Model
  factory LayananModel.fromJson(Map<String, dynamic> json) {
    return LayananModel(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      kode: json['kode'] ?? '',
      jamBuka: json['jamBuka'] ?? '07:00',
      jamTutup: json['jamTutup'] ?? '12:00',
      estimasiPerPasien: json['estimasiPerPasien'] ?? 10,
      aktif: json['aktif'] ?? true,
    );
  }

  // Convert dari Model ke Firebase JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'kode': kode,
      'jamBuka': jamBuka,
      'jamTutup': jamTutup,
      'estimasiPerPasien': estimasiPerPasien,
      'aktif': aktif,
    };
  }

  // Copy with method untuk update data
  LayananModel copyWith({
    String? id,
    String? nama,
    String? kode,
    String? jamBuka,
    String? jamTutup,
    int? estimasiPerPasien,
    bool? aktif,
  }) {
    return LayananModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      kode: kode ?? this.kode,
      jamBuka: jamBuka ?? this.jamBuka,
      jamTutup: jamTutup ?? this.jamTutup,
      estimasiPerPasien: estimasiPerPasien ?? this.estimasiPerPasien,
      aktif: aktif ?? this.aktif,
    );
  }
}