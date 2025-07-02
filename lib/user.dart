Future<void> addContact(String name, String phone, String email) async {
  final String userId =
      FirebaseAuth.instance.currentUser!.uid; // Dapatkan ID pemilik
  CollectionReference contacts = FirebaseFirestore.instance.collection(
    'contacts',
  );

  await contacts.add({
    'name': name,
    'phone': phone,
    'email': email,
    'ownerId': userId, // WAJIB: Sertakan ID pemilik
  });
  // Kembali ke halaman daftar kontak
}
