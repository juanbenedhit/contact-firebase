import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// mengimport package material dan cloud_firestore

import 'user.dart';
// mengimport file user

// Callback agar tahu ada perubahan
typedef ContactAlteredCallback = void Function();

// class editcontact
class EditContactPage extends StatefulWidget {
  final User user;
  // user yang akan diedit
  final ContactAlteredCallback onContactAltered;

  // constructor editcontact
  const EditContactPage({
    super.key,
    required this.user,
    required this.onContactAltered,
  });

  @override
  State<EditContactPage> createState() => _EditContactPageState();
}

// clas edtcontact state
class _EditContactPageState extends State<EditContactPage> {
  // koneksi dengan firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Nama koleksi di Firestore
  final String _collectionName = 'contacts';

  // variabel untuk edit form
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isSaving = false;
  bool _isDeleting = false;

  //
  @override
  void initState() {
    super.initState();
    // Inisiasasi controller dengan data kontak yang ada
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    // membersihkan controller
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // untuk mengecek apakah form valid
  Future<void> _updateContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (widget.user.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // menampilkan loading
    setState(() {
      _isSaving = true;
    });

    // mengambil data
    try {
      // mengupdate data
      await _firestore.collection(_collectionName).doc(widget.user.id).update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      widget.onContactAltered();

      //jika berhasil maka kembalikan ke halaman sebelumnya dan menampilkan snackbar
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact Edited Successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // jika gagal maka tampilkan snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update contact: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // menyembunyikan loading
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // menghapus contact
  Future<void> _deleteContact() async {
    if (widget.user.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: ID not found.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // konfirmasi menghapus contact
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // bagian dialog konfirmasi delete
          title: const Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete ${widget.user.firstName} ${widget.user.lastName}?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                // jika cancle maka menutup dialog
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                // jika delete maka menutup dialog dan delete
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    // jika confirm delete
    if (confirmDelete == true) {
      setState(() {
        _isDeleting = true;
      });
      try {
        // menghapus data
        await _firestore
            .collection(_collectionName)
            .doc(widget.user.id)
            .delete();
        // memanggil fungsi onContactAltered
        widget.onContactAltered();

        if (mounted) {
          // jika berhasil maka kembali ke halaman sebelumnya
          int popCount = 0;
          Navigator.of(context).popUntil((_) => popCount++ >= 1);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contact Deleted Successfully'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          // jika gagal mengdelete maka tampilkan snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete contact: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isDeleting = false;
          });
        }
      }
    }
  }

  // bagian menampilkan edit contact
  @override
  Widget build(BuildContext context) {
    // Tombol Save atau Delete tidak aktif jika salah satu proses sedang berjalan
    final bool buttonsEnabled = !_isSaving && !_isDeleting;

    return Scaffold(
      appBar: AppBar(
        // bagian appbar mengatur title, jarak, warna, dan sizebox
        title: Text('Edit ${widget.user.firstName}'),
        actions: [
          if (_isSaving)
            // jika melakuakn saving
            const Padding(
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
          else
            // jikia tidak
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: TextButton(
                onPressed: buttonsEnabled ? _updateContact : null,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('SAVE'),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        // bagian body mengatur form, padding, jarak
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

              // Jarak antara button delete dan form
              const SizedBox(height: 32),
              if (_isDeleting)
                const Center(child: CircularProgressIndicator())
              else
                FilledButton.icon(
                  icon: const Icon(Icons.delete_forever_outlined),
                  label: const Text('Delete This Contact'),
                  onPressed: buttonsEnabled ? _deleteContact : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                ),
              const SizedBox(height: 16), // Jarak di bawah tombol delete
            ],
          ),
        ),
      ),
    );
  }
}
