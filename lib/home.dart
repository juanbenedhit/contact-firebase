import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// mengimport package material dan cloud_firestore

import 'user.dart';
import 'contact.dart';
import 'add_contact.dart';
// mengimport file user, add_contact, dan contact

// halaman homepage untuk menampilkan daftar kontak dengna memanggil class _HomePageState
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// class _HomePageState untuk menampilkan daftar kontak
class _HomePageState extends State<HomePage> {
  // varibel untuk menampilkan daftar kontak sesaui filter atau seacrh
  List<User> _users = [];
  List<User> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _errorMessage = '';

  // variabel untuk floating action button
  final bool _showFab = true;
  final bool _showNotch = true;

  // instansiasi firestore dengan nama collection yang sama dengan firestone
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'contacts';

  //untuk mengambil data dari firestore ke homepage
  @override
  void initState() {
    super.initState();
    _fetchUsersFromFirestore();
    _searchController.addListener(_filterUsers);
    // menambahkan listener ke search bar
  }

  // untuk menghapus listener
  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  // bagian untuk mengambil data dari firestone
  Future<void> _fetchUsersFromFirestore() async {
    // menampilkan loading
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // mengambil data dengan try catch
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(_collectionName).get();

      // mengecek apakah data tidak kosong
      if (querySnapshot.docs.isNotEmpty) {
        List<User> tempUsers = [];
        for (var doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            try {
              User user = User.fromFirestore(data, doc.id);
              tempUsers.add(user);
            } catch (e) {
              // menampilkan text error
            }
          }
        }

        // untuk mengurutkan data
        if (tempUsers.isNotEmpty) {
          tempUsers.sort(
            (a, b) =>
                a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase()),
          );
          // mengupdate data baru
          setState(() {
            _users = tempUsers;
            _filteredUsers = _users;
            _isLoading = false;
            _errorMessage = '';
          });
        } else {
          // ketika error karena data tidak valid atau tipe datanya berbeda dengan firestone
          setState(() {
            _errorMessage =
                'Tidak ada data kontak valid yang dapat ditampilkan.';
            _isLoading = false;
            _users = [];
            _filteredUsers = [];
          });
        }
      } else {
        // ketika data kosong
        setState(() {
          _errorMessage =
              "Tidak ada data kontak ditemukan di database untuk koleksi '$_collectionName'.";
          _isLoading = false;
          _users = [];
          _filteredUsers = [];
        });
      }
    } catch (e) {
      // error handling jika terjadi kesalahan pada saat mengambil data atau konksi bermasalah pada firebase
      setState(() {
        _errorMessage =
            'Terjadi kesalahan saat mengambil data: $e. Periksa koneksi dan konfigurasi Firebase.';
        _isLoading = false;
        _users = [];
        _filteredUsers = [];
      });
    }
  }

  // untuk mencari kontak berdasarkan nama, email, atua nomor
  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers =
          _users.where((user) {
            final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
            final email = user.email.toLowerCase();
            final phone = user.phone?.toLowerCase() ?? '';
            return fullName.contains(query) ||
                email.contains(query) ||
                phone.contains(query);
          }).toList();
    });
  }

  // untuk pindah ke page add contact
  void _navigateToAddContactPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddContactPage(
              onContactSaved: () {
                _fetchUsersFromFirestore();
              },
            ),
      ),
    );
  }

  // bagian menampilkan kontak
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bagian appbar mengatur jarak, border, search bar, warna, dan icon
      appBar: AppBar(
        title: const Text(
          'Contact',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Contact',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
              ),
            ),
          ),
        ),
      ),

      // baigan body
      body:
          // bagian loading jika data sedang di load dan mengatur jarak dan font size
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
              // bagian refresh jika data telah di load
              : RefreshIndicator(
                onRefresh: _fetchUsersFromFirestore,
                child:
                    // ketika mencari data berdasarkan nama, email, atau nomor
                    _filteredUsers.isEmpty && !_isLoading
                        ? Center(
                          child: Text(
                            // jika data tida ada
                            _searchController.text.isEmpty
                                ? 'Tidak ada kontak untuk ditampilkan.'
                                : 'Tidak ada hasil untuk "${_searchController.text}".',
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                        : ListView.builder(
                          // mengatur jarak, padding, dan item count
                          padding: const EdgeInsets.only(
                            top: 8.0,
                            bottom: 88.0,
                          ),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return ContactTile(
                              user: user,
                              onContactAltered: () {},
                            );
                          },
                        ),
              ),

      // bagian floating button tambah contact
      floatingActionButton:
          // mengatur floating button dan icon dan ketika di klik bisa berpindah kehalaan add contact
          _showFab
              ? FloatingActionButton(
                onPressed:
                    _navigateToAddContactPage, // Menggunakan fungsi navigasi
                tooltip: 'Add Contact',
                child: const Icon(Icons.add),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: _HomeBottomAppBar(
        shape: _showNotch ? const CircularNotchedRectangle() : null,
      ),
    );
  }
}

// bagian bottom app bar
class _HomeBottomAppBar extends StatelessWidget {
  const _HomeBottomAppBar({this.shape = const CircularNotchedRectangle()});

  final NotchedShape? shape;

  @override
  Widget build(BuildContext context) {
    // mengatur warna bottom app bar
    final colorScheme = Theme.of(context).colorScheme;

    return BottomAppBar(
      // mengatur warna bottom app bar, bentuk, jarak dna icon
      shape: shape,
      color: colorScheme.surfaceContainer,
      elevation: 0,
      height: 64,
      child: IconTheme(
        data: IconThemeData(color: colorScheme.onSurfaceVariant),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Kontak',
                icon: Icon(
                  Icons.contacts,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                onPressed: () {
                  // belum ada
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
