import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/admin_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final DatabaseReference _adminRef = FirebaseDatabase.instance.ref('admin');
  
  /// Get current user
  static User? get currentUser => _auth.currentUser;
  
  /// Check if user is logged in
  static bool get isLoggedIn => currentUser != null;
  
  /// Login with email and password
  static Future<AdminModel> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Step 1: Starting Firebase Auth login...');
      debugPrint('📧 Email: $email');
      
      // Step 1: Login to Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        debugPrint('❌ User credential is null');
        throw Exception('Login gagal: User credential null');
      }
      
      debugPrint('✅ Step 1 Success: Firebase Auth login successful');
      debugPrint('👤 User UID: ${userCredential.user!.uid}');
      
      // ... Step 1 selesai ...

      debugPrint('🔐 Step 2: Query admin by email...');
      
      // Query langsung ke database: Cari child yang 'email'-nya sama dengan input
      final query = _adminRef.orderByChild('email').equalTo(email);
      final snapshot = await query.get();

      if (!snapshot.exists) {
        debugPrint('❌ Admin data not found via query');
        throw Exception('Data admin tidak ditemukan di database');
      }

      // Ambil data pertama yang cocok (karena email harusnya unik)
      final dataMap = snapshot.value as Map<dynamic, dynamic>;
      final key = dataMap.keys.first;
      final value = Map<String, dynamic>.from(dataMap[key]);

      final admin = AdminModel.fromJson(key, value);
      
      debugPrint('✅ Step 3 Success: Admin found via Query!');
      debugPrint('👤 Admin name: ${admin.nama}');
      
      return admin;
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException: ${e.code}');
      debugPrint('❌ Message: ${e.message}');
      
      if (e.code == 'user-not-found') {
        throw Exception('Email tidak terdaftar');
      } else if (e.code == 'wrong-password') {
        throw Exception('Password salah');
      } else if (e.code == 'invalid-email') {
        throw Exception('Format email tidak valid');
      } else if (e.code == 'user-disabled') {
        throw Exception('Akun dinonaktifkan');
      } else if (e.code == 'network-request-failed') {
        throw Exception('Tidak ada koneksi internet');
      } else if (e.code == 'too-many-requests') {
        throw Exception('Terlalu banyak percobaan login. Coba lagi nanti');
      } else {
        throw Exception('Login gagal: ${e.message ?? e.code}');
      }
    } catch (e) {
      debugPrint('❌ General Exception: $e');
      
      // Re-throw if already an Exception with message
      if (e is Exception) {
        rethrow;
      }
      
      throw Exception('Terjadi kesalahan: $e');
    }
  }
  
  /// Logout
  static Future<void> logout() async {
    await _auth.signOut();
  }
  
  /// Get admin data by email
  static Future<AdminModel?> getAdminByEmail(String email) async {
    try {
      final snapshot = await _adminRef.get();
      if (!snapshot.exists) return null;
      
      final adminData = snapshot.value as Map<dynamic, dynamic>;
      
      for (var entry in adminData.entries) {
        final data = Map<String, dynamic>.from(entry.value);
        if (data['email'] == email) {
          return AdminModel.fromJson(entry.key, data);
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting admin by email: $e');
      return null;
    }
  }
  
  /// Auth state changes stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}
