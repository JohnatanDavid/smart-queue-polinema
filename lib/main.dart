import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/admin/display_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Queue - Multi Poli',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins', // ⬅️ Tambahkan font custom disini
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const SplashScreen(),
      
      // Routes untuk akses display terpisah
      routes: {
        '/display/poli_umum': (context) => const DisplayScreen(layananId: 'poli_umum'),
        '/display/poli_gigi': (context) => const DisplayScreen(layananId: 'poli_gigi'),
      },
    );
  }
}
