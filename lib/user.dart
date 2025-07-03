class User {
  // membuat objek user menggunakan data dari firestone
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? ownerId;

  // construktror untuk objek user
  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.ownerId,
  });

  // method untuk mengubah data dari firestore ke objek user
  factory User.fromFirestore(Map<String, dynamic> data, String documentId) {
    // mengubah phone menjadi string jika ada
    dynamic phoneData = data['phone'];
    String? phoneNumber;
    if (phoneData != null) {
      phoneNumber =
          phoneData
              .toString(); // Konversi ke String jika tidak null agar nantinya bisa di cari
    }

    return User(
      id: documentId,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: phoneNumber,
      ownerId: data['ownerId'] as String?,
    );
  }

  // Method untuk mengubah objek User menjadi Map untuk disimpan ke Firestore
  Map<String, dynamic> toJson() {
    // Saat menyimpan kembali ke Firestore, kita perlu memastikan 'phone' disimpan sebagai number jika ada
    if (phone != null && phone!.isNotEmpty) {
      // Coba parse String ke num
    }

    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'ownerId': ownerId,
    };
  }
}
