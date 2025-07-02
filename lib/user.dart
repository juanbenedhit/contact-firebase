// Model untuk data pengguna/kontak
class User {
  final String? id; // ID dokumen dari Firestore
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? ownerId;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.ownerId,
  });

  // Factory method untuk membuat objek User dari Map data Firestore
  factory User.fromFirestore(Map<String, dynamic> data, String documentId) {
    // Baca 'phone' sebagai num? lalu konversi ke String?
    dynamic phoneData = data['phone']; // Ambil data phone apa adanya dulu
    String? phoneNumber;
    if (phoneData != null) {
      phoneNumber = phoneData.toString(); // Konversi ke String jika tidak null
    }

    return User(
      id: documentId,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: phoneNumber,
      ownerId: data['ownerId'] as String?, // 'ownerId' bisa null
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
