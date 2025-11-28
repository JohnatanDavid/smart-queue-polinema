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
      
      // Step 2: Get admin data from Realtime Database
      debugPrint('🔐 Step 2: Fetching admin data from Realtime Database...');
      
      final snapshot = await _adminRef.get();
      
      if (!snapshot.exists) {
        debugPrint('❌ Admin node does not exist in database');
        throw Exception('Data admin tidak ditemukan di database');
      }
      
      debugPrint('✅ Step 2 Success: Admin data exists');
      
      final adminData = snapshot.value as Map<dynamic, dynamic>;
      debugPrint('📊 Admin data keys: ${adminData.keys.toList()}');
      
      // Step 3: Find admin by email
      debugPrint('🔐 Step 3: Searching for admin with email: $email');
      
      AdminModel? admin;
      for (var entry in adminData.entries) {
        debugPrint('🔍 Checking entry: ${entry.key}');
        final data = Map<String, dynamic>.from(entry.value);
        debugPrint('  - Email in DB: ${data['email']}');
        debugPrint('  - Match: ${data['email'] == email}');
        
        if (data['email'] == email) {
          admin = AdminModel.fromJson(entry.key, data);
          debugPrint('✅ Step 3 Success: Admin found!');
          debugPrint('👤 Admin name: ${admin.nama}');
          debugPrint('🏥 Loket ID: ${admin.loketId}');
          break;
        }
      }
      
      if (admin == null) {
        debugPrint('❌ Admin not found in database for email: $email');
        throw Exception('Admin dengan email $email tidak terdaftar di database');
      }
      
      debugPrint('🎉 Login successful!');
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