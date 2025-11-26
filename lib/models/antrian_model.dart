class AntrianModel {
  final String nomorAntrian;
  final int nomorUrut;
  final String layananId;
  final String namaLayanan;
  final String namaPasien;
  final int waktuAmbil;
  final String status;
  final String? loketId;
  final int? waktuPanggil;
  final int? waktuSelesai;

  AntrianModel({
    required this.nomorAntrian,
    required this.nomorUrut,
    required this.layananId,
    required this.namaLayanan,
    required this.namaPasien,
    required this.waktuAmbil,
    required this.status,
    this.loketId,
    this.waktuPanggil,
    this.waktuSelesai,
  });

  // Convert dari Firebase JSON ke Model
  factory AntrianModel.fromJson(Map<String, dynamic> json) {
    return AntrianModel(
      nomorAntrian: json['nomorAntrian'] ?? '',
      nomorUrut: json['nomorUrut'] ?? 0,
      layananId: json['layananId'] ?? '',
      namaLayanan: json['namaLayanan'] ?? '',
      namaPasien: json['namaPasien'] ?? 'Anonim',
      waktuAmbil: json['waktuAmbil'] ?? DateTime.now().millisecondsSinceEpoch,
      status: json['status'] ?? 'menunggu',
      loketId: json['loketId'],
      waktuPanggil: json['waktuPanggil'],
      waktuSelesai: json['waktuSelesai'],
    );
  }

  // Convert dari Model ke Firebase JSON
  Map<String, dynamic> toJson() {
    return {
      'nomorAntrian': nomorAntrian,
      'nomorUrut': nomorUrut,
      'layananId': layananId,
      'namaLayanan': namaLayanan,
      'namaPasien': namaPasien,
      'waktuAmbil': waktuAmbil,
      'status': status,
      'loketId': loketId,
      'waktuPanggil': waktuPanggil,
      'waktuSelesai': waktuSelesai,
    };
  }

  // Copy with method untuk update data
  AntrianModel copyWith({
    String? nomorAntrian,
    int? nomorUrut,
    String? layananId,
    String? namaLayanan,
    String? namaPasien,
    int? waktuAmbil,
    String? status,
    String? loketId,
    int? waktuPanggil,
    int? waktuSelesai,
  }) {
    return AntrianModel(
      nomorAntrian: nomorAntrian ?? this.nomorAntrian,
      nomorUrut: nomorUrut ?? this.nomorUrut,
      layananId: layananId ?? this.layananId,
      namaLayanan: namaLayanan ?? this.namaLayanan,
      namaPasien: namaPasien ?? this.namaPasien,
      waktuAmbil: waktuAmbil ?? this.waktuAmbil,
      status: status ?? this.status,
      loketId: loketId ?? this.loketId,
      waktuPanggil: waktuPanggil ?? this.waktuPanggil,
      waktuSelesai: waktuSelesai ?? this.waktuSelesai,
    );
  }
}