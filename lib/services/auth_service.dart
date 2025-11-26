import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
      // Login to Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('Login gagal');
      }
      
      // Get admin data from Realtime Database
      final snapshot = await _adminRef.get();
      if (!snapshot.exists) {
        throw Exception('Data admin tidak ditemukan');
      }
      
      final adminData = snapshot.value as Map<dynamic, dynamic>;
      
      // Find admin by email
      AdminModel? admin;
      for (var entry in adminData.entries) {
        final data = Map<String, dynamic>.from(entry.value);
        if (data['email'] == email) {
          admin = AdminModel.fromJson(entry.key, data);
          break;
        }
      }
      
      if (admin == null) {
        throw Exception('Admin tidak ditemukan');
      }
      
      return admin;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Email tidak terdaftar');
      } else if (e.code == 'wrong-password') {
        throw Exception('Password salah');
      } else if (e.code == 'invalid-email') {
        throw Exception('Format email tidak valid');
      } else if (e.code == 'user-disabled') {
        throw Exception('Akun dinonaktifkan');
      } else {
        throw Exception('Login gagal: ${e.message}');
      }
    } catch (e) {
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
      return null;
    }
  }
  
  /// Auth state changes stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}