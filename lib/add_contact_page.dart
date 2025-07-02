import 'package:flutter/material.dart';

class AddContactPage extends StatefulWidget {
  final Function(String name, String phoneNumber) addContact;

  const AddContactPage({Key? key, required this.addContact}) : super(key: key);

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Panggil fungsi addContact dengan data dari formulir
      widget.addContact(_nameController.text, _phoneController.text);

      // Kembali ke halaman sebelumnya
      Navigator.pop(context);
    }
  }

  @override
  Widget build

  (

  BuildContext.context) {
  return Scaffold(
  appBar: AppBar(
  title: const Text('Tambah Kontak Baru'),
  ),
  body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Form(
  key: _formKey,
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: <Widget>[
  TextFormField(
  controller: _nameController,
  decoration: const InputDecoration(labelText: 'Nama'),
  validator: (value) {
  if (value == null || value.isEmpty) {
  return 'Nama tidak boleh kosong';
  }
  return null;
  },
  ),
  const SizedBox(height: 16.0),
  TextFormField(
  controller: _phoneController,
  decoration: const InputDecoration(labelText: 'Nomor Telepon'),
  keyboardType: TextInputType.phone,
  validator: (value) {
  if (value == null || value.isEmpty) {
  return 'Nomor telepon tidak boleh kosong';
  }
  // Anda bisa menambahkan validasi nomor telepon yang lebih spesifik di sini
  return null;
  },
  ),
  const SizedBox(height: 24.0),
  ElevatedButton(
  onPressed: _submitForm,
  child: const Text('Simpan'),
  ),
  ],
  ),
  ),
  ),
  );
  }
}