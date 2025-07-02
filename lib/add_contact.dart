import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef ContactSavedCallback = void Function();

class AddContactPage extends StatefulWidget {
  final ContactSavedCallback onContactSaved;

  const AddContactPage({super.key, required this.onContactSaved});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName =
      'contacts'; // Sesuaikan jika nama koleksi berbeda

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) {
      return; // Jika form tidak valid, jangan lakukan apa-apa
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String phoneText = _phoneController.text.trim();
      num? phoneNumberForFirestore;
      if (phoneText.isNotEmpty) {
        phoneNumberForFirestore = num.tryParse(phoneText);
      }

      await _firestore.collection(_collectionName).add({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': phoneNumberForFirestore,
        'ownerId': "user_tes_123", // Sesuai permintaan Anda
      });

      widget.onContactSaved(); // Panggil callback

      if (mounted) {
        Navigator.of(context).pop(); // Tutup halaman tambah kontak
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact Created!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed To Create Contact. Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding =
        screenWidth * 0.1; // Misalnya, 10% dari lebar layar di setiap sisi

    const Color darkBlueColor = Color(0xFF003366);
    const double avatarSpacing = 20.0; // Definisikan jarak yang sama

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kontak Baru'),
        actions: [
          _isSaving
              ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: TextButton(
                  onPressed: _saveContact,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: darkBlueColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text('SAVE'),
                ),
              ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: avatarSpacing,
            horizontal: horizontalPadding,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // --- AWAL: CircleAvatar untuk representasi foto profil ---
                const CircleAvatar(
                  radius: 50, // Sesuaikan ukuran radius sesuai keinginan
                  backgroundColor:
                      Colors.grey, // Warna latar belakang jika tidak ada gambar
                  // Anda bisa menampilkan ikon default jika tidak ada gambar
                  child: Icon(
                    Icons.person,
                    size: 60, // Sesuaikan ukuran ikon
                    color: Colors.white, // Warna ikon
                  ),
                  // Jika Anda memiliki URL gambar statis, Anda bisa menggunakan:
                  // backgroundImage: NetworkImage('URL_GAMBAR_ANDA_DISINI'),
                  // Atau jika gambar dari assets:
                  // backgroundImage: AssetImage('assets/nama_gambar.png'),
                ),
                const SizedBox(
                  height: avatarSpacing,
                ), // Jarak antara avatar dan form
                // --- AKHIR: CircleAvatar ---
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'First Name cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email cannot be empty';
                    }
                    if (!RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                    ).hasMatch(value)) {
                      return 'Email not valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
