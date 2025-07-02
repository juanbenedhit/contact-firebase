import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'home.dart'; // Berisi ContactListPage
import 'login_page.dart'; // Halaman UI untuk login (perlu dibuat)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Kontak',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: AuthGate(), // Gunakan AuthGate sebagai halaman utama
    );
  }
}

// Widget untuk memeriksa status login
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Jika belum login, tampilkan halaman login
        if (!snapshot.hasData) {
          return LoginPage(); // Anda perlu membuat file dan widget LoginPage ini
        }
        // Jika sudah login, tampilkan daftar kontak
        return const ContactListPage();
      },
    );
  }
}
