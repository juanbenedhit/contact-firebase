// mengimport material dari fluttter dan file user.dart
import 'package:flutter/material.dart';
import 'user.dart';
import 'edit_contact.dart';

class ContactTile extends StatelessWidget {
  final User user;
  final VoidCallback onContactAltered; // Callback untuk refresh di HomePage
  const ContactTile({
    super.key,
    required this.user,
    required this.onContactAltered,
  });

  @override
  Widget build(BuildContext context) {
    String getInitials(String firstName, String lastName) {
      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        return '${firstName[0]}${lastName[0]}'.toUpperCase();
      } else if (firstName.isNotEmpty) {
        return firstName[0].toUpperCase();
      } else if (lastName.isNotEmpty) {
        return lastName[0].toUpperCase();
      }
      //mencari insial dari nama lengkap
      return '';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      // memberikan margin pada bagian card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        // memberikan efek round untuk bagian card
      ),
      elevation: 0,
      // menghiilangkan shadow pada bagian card
      child: ListTile(
        // menampilkan informasi kontak dengan list
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            getInitials(user.firstName, user.lastName),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ), // menampilkan profile picture sebagai inisial dari naam dengan warna background, dana font bold

        title: Text(
          '${user.firstName} ${user.lastName}',
        ), // Tampilkan nama lengkap dengan cara menggabungkan nama depan dan nama belaakng

        subtitle: Text(user.email), // menampilkan email
        onTap: () {
          // GANTI SNACKBAR DENGAN NAVIGASI KE EditContactPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => EditContactPage(
                    user: user, // Kirim data user yang dipilih
                    onContactAltered:
                        onContactAltered, // Teruskan callback ke EditContactPage
                  ),
            ),
          );
        },
      ),
    );
  }
}
