import 'package:flutter/material.dart';
// mengimport material dari fluttter dan file user.dart

import 'user.dart';
import 'edit_contact.dart';
// mengimport file user dan edit contact

// bagian widget untuk menampilkan kontak
class ContactTile extends StatelessWidget {
  final User user;

  // Callback untuk refresh di HomePage
  final VoidCallback onContactAltered;

  // constructor
  const ContactTile({
    super.key,
    required this.user,
    required this.onContactAltered,
  });

  // menampilkan informasi kontak dengan mencari inisial dari nama depan dan nama belakang
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
      return '';
    }

    // menampilkan informasi kontak
    return Card(
      // mengatur margin, shape, dan shadow
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 0,

      // bagian list
      child: ListTile(
        // mengatur tampilan list contact
        leading: CircleAvatar(
          // menampilkan profile picture didapatkan dari inisial
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            getInitials(user.firstName, user.lastName),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // menampilkan nama lengkap
        title: Text('${user.firstName} ${user.lastName}'),
        // menampilkan email
        subtitle: Text(user.email),

        // ketika mengeklik list contact akan berpindah ke edit contact
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => EditContactPage(
                    user: user,
                    onContactAltered: onContactAltered,
                  ),
            ),
          );
        },
      ),
    );
  }
}
