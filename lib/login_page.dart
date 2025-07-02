import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// (Tempatkan fungsi registerUser dan loginUser di sini atau impor dari file lain)
Future<void> registerUser(String email, String password) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Jika berhasil, navigasi ke halaman daftar kontak
    // Misalnya: Navigator.pushReplacementNamed(context, '/contactList');
    print('Registrasi berhasil!');
  } on FirebaseAuthException catch (e) {
    // Tangani error, misalnya email sudah terdaftar
    print('Error registrasi: ${e.message}');
    // Tampilkan pesan error ke pengguna, misalnya dengan SnackBar
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
  }
}

Future<void> loginUser(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Jika berhasil, navigasi ke halaman daftar kontak
    // Misalnya: Navigator.pushReplacementNamed(context, '/contactList');
    print('Login berhasil!');
  } on FirebaseAuthException catch (e) {
    // Tangani error, misalnya password salah
    print('Error login: ${e.message}');
    // Tampilkan pesan error ke pengguna
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Untuk validasi form

  bool _isLoading = false; // Untuk menampilkan indikator loading

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await registerUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // Anda mungkin ingin menavigasi atau menampilkan pesan sukses di sini
      // berdasarkan logika di dalam registerUser
      if (mounted) {
        // Pastikan widget masih ada di tree
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // Anda mungkin ingin menavigasi atau menampilkan pesan sukses di sini
      // berdasarkan logika di dalam loginUser
      if (mounted) {
        // Pastikan widget masih ada di tree
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!value.contains('@')) {
                    return 'Masukkan email yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _handleLogin,
                        child: const Text('Login'),
                      ),
                      ElevatedButton(
                        onPressed: _handleRegister,
                        child: const Text('Register'),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
