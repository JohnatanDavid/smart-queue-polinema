import 'package:intl/intl.dart';

class Helpers {
  // Format tanggal untuk database (YYYY-MM-DD)
  static String formatDateForDb(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  // Format tanggal untuk tampilan (DD-MM-YYYY)
  static String formatDateForDisplay(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }
  
  // Format waktu (HH:mm)
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
  
  // Format timestamp untuk tampilan (DD MMM YYYY, HH:mm)
  static String formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }
  
  // Generate nomor antrian (A001, B001, etc.)
  static String generateNomorAntrian(String kodeLayanan, int nomorUrut) {
    return '$kodeLayanan${nomorUrut.toString().padLeft(3, '0')}';
  }
  
  // Hitung estimasi waktu tunggu (dalam menit)
  static int hitungEstimasiWaktu(int sisaAntrian, int estimasiPerPasien) {
    return sisaAntrian * estimasiPerPasien;
  }
  
  // Format estimasi waktu tunggu untuk tampilan
  static String formatEstimasiWaktu(int menit) {
    if (menit < 60) {
      return '$menit menit';
    } else {
      final jam = menit ~/ 60;
      final sisaMenit = menit % 60;
      if (sisaMenit == 0) {
        return '$jam jam';
      }
      return '$jam jam $sisaMenit menit';
    }
  }
  
  // Cek apakah waktu sekarang dalam jam operasional
  static bool isJamOperasional(String jamBuka, String jamTutup) {
    try {
      final now = DateTime.now();
      final format = DateFormat('HH:mm');
      
      final buka = format.parse(jamBuka);
      final tutup = format.parse(jamTutup);
      final sekarang = format.parse(DateFormat('HH:mm').format(now));
      
      final bukaTime = DateTime(now.year, now.month, now.day, buka.hour, buka.minute);
      final tutupTime = DateTime(now.year, now.month, now.day, tutup.hour, tutup.minute);
      final sekarangTime = DateTime(now.year, now.month, now.day, sekarang.hour, sekarang.minute);
      
      return sekarangTime.isAfter(bukaTime) && sekarangTime.isBefore(tutupTime);
    } catch (e) {
      return false;
    }
  }
  
  // Get tanggal hari ini untuk key database
  static String getTodayKey() {
    return formatDateForDb(DateTime.now());
  }
}