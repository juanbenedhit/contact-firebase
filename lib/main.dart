import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// mengimport package material dan firebase

import 'home.dart';
import 'firebase_options.dart';
// Import file home.dart dan konfigurasi Firebase

// menggunakan async untuk memastikan Firebase siap
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Inisialisasi Firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// class MyApp unutk menampilkan aplikasi menggunakna material design 3
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      // memnggunakna material3 dan skema berwarna hijau
      home: const HomePage(),
      // halaman utama
    );
  }
}
