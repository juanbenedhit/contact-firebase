// mengimport material dari flutter dan file home.dart
import 'package:flutter/material.dart';
import 'home.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'firebase_options.dart'; // Import file konfigurasi Firebase (dihasilkan oleh flutterfire configure)

void main() async {
  // Ubah main menjadi async
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan Flutter binding sudah siap
  await Firebase.initializeApp(
    // Inisialisasi Firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Kontak',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      // memnggunakna material3 dan skema warna hijau
      home: const HomePage(),
      // menampilkan halaman utama
    );
  }
}
