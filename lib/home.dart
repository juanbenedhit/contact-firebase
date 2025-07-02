import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_contact_page.dart'; // Impor halaman edit yang akan kita buat

class ContactListPage extends StatelessWidget {
  const ContactListPage({super.key});

  // Fungsi untuk menghapus kontak
  Future<void> _deleteContact(BuildContext context, String docId) async {
    // Tampilkan dialog konfirmasi
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus kontak ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('contacts')
                    .doc(docId)
                    .delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text('My Contacts')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('contacts')
                .where('ownerId', isEqualTo: userId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No contacts found.'));
          }

          var docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var contact = docs[index];
              String docId = contact.id;
              Map<String, dynamic> data =
                  contact.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['name']),
                subtitle: Text(data['phone']),
                // AKSI UPDATE: Ketuk untuk mengedit
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditContactPage(
                            docId: docId,
                            currentName: data['name'],
                            currentPhone: data['phone'],
                            currentEmail: data['email'],
                          ),
                    ),
                  );
                },
                // AKSI DELETE: Tombol ikon hapus
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteContact(context, docId),
                ),
              );
            },
          );
        },
      ),
      // ... FloatingActionButton ...
    );
  }
}
