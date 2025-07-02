import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart'; // Pastikan model User Anda sudah ada

// Callback untuk memberi tahu halaman sebelumnya bahwa ada perubahan (edit/delete)
// dan mungkin perlu me-refresh daftar kontak.
typedef ContactAlteredCallback = void Function();

class EditContactPage extends StatefulWidget {
  final User user; // Kontak yang akan diedit
  final ContactAlteredCallback onContactAltered;

  const EditContactPage({
    super.key,
    required this.user,
    required this.onContactAltered,
  });

  @override
  State<EditContactPage> createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'contacts'; // Nama koleksi di Firestore

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data kontak yang ada
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (widget.user.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: ID Kontak tidak ditemukan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
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

      await _firestore.collection(_collectionName).doc(widget.user.id).update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': phoneNumberForFirestore,
        // Anda mungkin ingin memperbarui field lain jika ada,
        // misalnya 'ownerId' jika itu bisa diubah.
      });

      widget.onContactAltered(); // Panggil callback

      if (mounted) {
        Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kontak Berhasil Diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui kontak: $e'),
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

  Future<void> _deleteContact() async {
    if (widget.user.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: ID Kontak tidak ditemukan untuk dihapus.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Tampilkan dialog konfirmasi sebelum menghapus
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus kontak ${widget.user.firstName} ${widget.user.lastName}?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(false); // Tidak jadi hapus
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () {
                Navigator.of(context).pop(true); // Ya, hapus
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        _isDeleting = true;
      });
      try {
        await _firestore
            .collection(_collectionName)
            .doc(widget.user.id)
            .delete();
        widget.onContactAltered(); // Panggil callback

        if (mounted) {
          // Kembali dua kali untuk menutup halaman edit dan dialog (jika ada)
          // atau kembali ke daftar kontak utama
          int popCount = 0;
          Navigator.of(context).popUntil((_) => popCount++ >= 1);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kontak berhasil dihapus!'),
              backgroundColor: Colors.orange, // Warna berbeda untuk delete
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus kontak: $e'),
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

  @override
  Widget build(BuildContext context) {
    // Tombol Save atau Delete tidak aktif jika salah satu proses sedang berjalan
    final bool buttonsEnabled = !_isSaving && !_isDeleting;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.user.firstName}'), // Judul dinamis
        actions: [
          if (_isSaving)
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
                  // ... (kode style lainnya)
                ),
                child: const Text('SAVE'),
              ),
            ),
        ],
      ),
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
                  labelText: 'Nama Depan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama depan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Belakang',
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
                    return 'Email tidak boleh kosong';
                  }
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
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32), // Jarak sebelum tombol delete
              if (_isDeleting)
                const Center(child: CircularProgressIndicator())
              else
                FilledButton.icon(
                  icon: const Icon(Icons.delete_forever_outlined),
                  label: const Text('Hapus Kontak Ini'),
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
