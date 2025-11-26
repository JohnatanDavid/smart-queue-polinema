import 'package:flutter/material.dart';

// Colors
class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03A9F4);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color danger = Color(0xFFE91E63);
  static const Color dark = Color(0xFF263238);
  static const Color light = Color(0xFFECEFF1);
}

// Status Antrian
class StatusAntrian {
  static const String menunggu = 'menunggu';
  static const String dipanggil = 'dipanggil';
  static const String selesai = 'selesai';
  static const String batal = 'batal';
}

// Status Loket
class StatusLoket {
  static const String tersedia = 'tersedia';
  static const String sibuk = 'sibuk';
  static const String offline = 'offline';
}

// Firebase Paths
class FirebasePaths {
  static const String layanan = 'layanan';
  static const String antrian = 'antrian';
  static const String loket = 'loket';
  static const String admin = 'admin';
}

// Text Styles
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.dark,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.dark,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.dark,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.dark,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );
  
  static const TextStyle nomorAntrian = TextStyle(
    fontSize: 72,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    letterSpacing: 8,
  );
}

// Spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

// Border Radius
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}