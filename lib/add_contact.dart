import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// mengimport package material dan cloud firestore

// Callback agar tahu ada perubahan
typedef ContactSavedCallback = void Function();

// class addcontact
class AddContactPage extends StatefulWidget {
  final ContactSavedCallback onContactSaved;

  // constructor
  const AddContactPage({super.key, required this.onContactSaved});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

// class addcontact state
class _AddContactPageState extends State<AddContactPage> {
  // koneksi dengan firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Nama koleksi di Firestore
  final String _collectionName = 'contacts';

  // variabel untuk form
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    // membersihkan controller
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // fungsi untuk menyimpan kontak
  Future<void> _saveContact() async {
    // Jika tidak valid tidak melakukan apa apa
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // menampilkan loading
    setState(() {
      _isSaving = true;
    });

    // menambahkan data
    try {
      await _firestore.collection(_collectionName).add({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'ownerId': "user_tes_123",
      });

      widget.onContactSaved();

      if (mounted) {
        // jika berhasil maka menutup dialog dan menampilkan snackbar
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact Added Successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // jika gagal maka menampilkan snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add contact. Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        // menyembunyikan loading
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // bagian menampilkan kontak
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // bagian appbar mengatur title, padding, warnam jarak
        title: const Text('Add Contact'),
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
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text('SAVE'),
                ),
              ),
        ],
      ),

      // bagian body mengatur padding, jarak, form,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 60),
              ),
              const SizedBox(height: 30),

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

                  // bagian validasai email
                  if (!RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  ).hasMatch(value)) {
                    return 'Format email tidak valid';
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
    );
  }
}
