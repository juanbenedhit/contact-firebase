import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditContactPage extends StatefulWidget {
  final String docId;
  final String currentName;
  final String currentPhone;
  final String currentEmail;

  const EditContactPage({
    super.key,
    required this.docId,
    required this.currentName,
    required this.currentPhone,
    required this.currentEmail,
  });

  @override
  State<EditContactPage> createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    // Isi controller dengan data yang ada saat halaman dibuka
    _nameController = TextEditingController(text: widget.currentName);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _emailController = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Fungsi untuk update kontak
  Future<void> _updateContact() async {
    if (widget.docId.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('contacts')
          .doc(widget.docId)
          .update({
            'name': _nameController.text,
            'phone': _phoneController.text,
            'email': _emailController.text,
          });

      // Kembali ke halaman sebelumnya jika berhasil
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Tampilkan error jika gagal
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update contact: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Contact')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _updateContact,
              child: Text('Update Contact'),
            ),
          ],
        ),
      ),
    );
  }
}
