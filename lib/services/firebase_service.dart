import 'package:firebase_database/firebase_database.dart';
import '../models/layanan_model.dart';
import '../models/antrian_model.dart';
import '../models/loket_model.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';

class FirebaseService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  
  // References
  static DatabaseReference get _layananRef => _database.ref('layanan');
  static DatabaseReference get _antrianRef => _database.ref('antrian');
  static DatabaseReference get _loketRef => _database.ref('loket');
  
  // ==================== LAYANAN ====================
  
  /// Get all layanan (streaming)
  static Stream<List<LayananModel>> getLayananStream() {
    return _layananRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      
      return data.entries.map((entry) {
        return LayananModel.fromJson(Map<String, dynamic>.from(entry.value));
      }).where((layanan) => layanan.aktif).toList();
    });
  }
  
  /// Get layanan by ID
  static Future<LayananModel?> getLayananById(String id) async {
    final snapshot = await _layananRef.child(id).get();
    if (!snapshot.exists) return null;
    
    return LayananModel.fromJson(
      Map<String, dynamic>.from(snapshot.value as Map)
    );
  }
  
  // ==================== ANTRIAN ====================
  
  /// Ambil nomor antrian baru
  static Future<AntrianModel> ambilNomorAntrian({
    required String layananId,
    String namaPasien = 'Anonim',
  }) async {
    try {
      // Get layanan info
      final layanan = await getLayananById(layananId);
      if (layanan == null) {
        throw Exception('Layanan tidak ditemukan');
      }
      
      // Get today's date key
      final todayKey = Helpers.getTodayKey();
      
      // Get current queue for this service today
      final antrianRef = _antrianRef.child(todayKey).child(layananId);
      final snapshot = await antrianRef.get();
      
      // Calculate next queue number
      int nomorUrut = 1;
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        nomorUrut = data.length + 1;
      }
      
      // Generate queue number
      final nomorAntrian = Helpers.generateNomorAntrian(
        layanan.kode,
        nomorUrut,
      );
      
      // Create new antrian
      final newAntrian = AntrianModel(
        nomorAntrian: nomorAntrian,
        nomorUrut: nomorUrut,
        layananId: layananId,
        namaLayanan: layanan.nama,
        namaPasien: namaPasien,
        waktuAmbil: DateTime.now().millisecondsSinceEpoch,
        status: StatusAntrian.menunggu,
      );
      
      // Save to Firebase
      await antrianRef.child(nomorAntrian).set(newAntrian.toJson());
      
      return newAntrian;
    } catch (e) {
      throw Exception('Gagal mengambil nomor antrian: $e');
    }
  }
  
  /// Get antrian by nomor
  static Stream<AntrianModel?> getAntrianByNomorStream(
    String nomorAntrian,
    String layananId,
  ) {
    final todayKey = Helpers.getTodayKey();
    return _antrianRef
        .child(todayKey)
        .child(layananId)
        .child(nomorAntrian)
        .onValue
        .map((event) {
      if (!event.snapshot.exists) return null;
      return AntrianModel.fromJson(
        Map<String, dynamic>.from(event.snapshot.value as Map)
      );
    });
  }
  
  /// Get all antrian for a service today (streaming)
  static Stream<List<AntrianModel>> getAntrianByLayananStream(String layananId) {
    final todayKey = Helpers.getTodayKey();
    return _antrianRef
        .child(todayKey)
        .child(layananId)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      
      final antrianList = data.entries.map((entry) {
        return AntrianModel.fromJson(
          Map<String, dynamic>.from(entry.value)
        );
      }).toList();
      
      // Sort by nomorUrut
      antrianList.sort((a, b) => a.nomorUrut.compareTo(b.nomorUrut));
      return antrianList;
    });
  }
  
  /// Get antrian menunggu (untuk admin)
  static Stream<List<AntrianModel>> getAntrianMenungguStream(String layananId) {
    return getAntrianByLayananStream(layananId).map((antrianList) {
      return antrianList
          .where((a) => a.status == StatusAntrian.menunggu)
          .toList();
    });
  }
  
  /// Update status antrian
  static Future<void> updateStatusAntrian({
    required String nomorAntrian,
    required String layananId,
    required String status,
    String? loketId,
  }) async {
    final todayKey = Helpers.getTodayKey();
    final updates = <String, dynamic>{
      'status': status,
    };
    
    if (loketId != null) {
      updates['loketId'] = loketId;
    }
    
    if (status == StatusAntrian.dipanggil) {
      updates['waktuPanggil'] = DateTime.now().millisecondsSinceEpoch;
    } else if (status == StatusAntrian.selesai) {
      updates['waktuSelesai'] = DateTime.now().millisecondsSinceEpoch;
    }
    
    await _antrianRef
        .child(todayKey)
        .child(layananId)
        .child(nomorAntrian)
        .update(updates);
  }
  
  /// Get statistik antrian
  static Future<Map<String, int>> getStatistikAntrian(String layananId) async {
    final todayKey = Helpers.getTodayKey();
    final snapshot = await _antrianRef.child(todayKey).child(layananId).get();
    
    if (!snapshot.exists) {
      return {
        'total': 0,
        'menunggu': 0,
        'dipanggil': 0,
        'selesai': 0,
      };
    }
    
    final data = snapshot.value as Map<dynamic, dynamic>;
    final antrianList = data.entries.map((entry) {
      return AntrianModel.fromJson(
        Map<String, dynamic>.from(entry.value)
      );
    }).toList();
    
    return {
      'total': antrianList.length,
      'menunggu': antrianList.where((a) => a.status == StatusAntrian.menunggu).length,
      'dipanggil': antrianList.where((a) => a.status == StatusAntrian.dipanggil).length,
      'selesai': antrianList.where((a) => a.status == StatusAntrian.selesai).length,
    };
  }
  
  /// Cek apakah user sudah punya antrian aktif
  static Future<AntrianModel?> cekAntrianAktif({
    required String layananId,
    required String namaPasien,
  }) async {
    final todayKey = Helpers.getTodayKey();
    final snapshot = await _antrianRef.child(todayKey).child(layananId).get();
    
    if (!snapshot.exists) return null;
    
    final data = snapshot.value as Map<dynamic, dynamic>;
    
    // Cari antrian dengan nama yang sama dan status aktif (menunggu atau dipanggil)
    for (var entry in data.entries) {
      final antrianData = Map<String, dynamic>.from(entry.value);
      final antrian = AntrianModel.fromJson(antrianData);
      
      if (antrian.namaPasien.toLowerCase() == namaPasien.toLowerCase() &&
          (antrian.status == StatusAntrian.menunggu || 
           antrian.status == StatusAntrian.dipanggil)) {
        return antrian;
      }
    }
    
    return null;
  }
  
  // ==================== LOKET ====================
  
  /// Get loket by ID (streaming)
  static Stream<LoketModel?> getLoketByIdStream(String loketId) {
    return _loketRef.child(loketId).onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return LoketModel.fromJson(
        Map<String, dynamic>.from(event.snapshot.value as Map)
      );
    });
  }
  
  /// Update loket antrian saat ini
  static Future<void> updateLoketAntrian(
    String loketId,
    String? nomorAntrian,
  ) async {
    await _loketRef.child(loketId).update({
      'antrianSaatIni': nomorAntrian,
      'status': nomorAntrian != null ? StatusLoket.sibuk : StatusLoket.tersedia,
    });
  }
  
  /// Get antrian yang sedang dilayani di loket (streaming)
  static Stream<AntrianModel?> getAntrianDiLoketStream(
    String loketId,
    String layananId,
  ) {
    return getLoketByIdStream(loketId).asyncMap((loket) async {
      if (loket?.antrianSaatIni == null) return null;
      
      final todayKey = Helpers.getTodayKey();
      final snapshot = await _antrianRef
          .child(todayKey)
          .child(layananId)
          .child(loket!.antrianSaatIni!)
          .get();
      
      if (!snapshot.exists) return null;
      
      return AntrianModel.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map)
      );
    });
  }
}