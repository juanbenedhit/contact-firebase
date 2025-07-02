import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';
import 'contact.dart';
import 'add_contact.dart'; // Pastikan ini diimport untuk navigasi

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<User> _users = [];
  List<User> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _errorMessage = '';

  final bool _showFab = true;
  final bool _showNotch = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // ! PENTING: Ganti 'users' di bawah ini jika nama koleksi Anda di Firestore berbeda!
  final String _collectionName = 'contacts';

  @override
  void initState() {
    super.initState();
    _fetchUsersFromFirestore();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsersFromFirestore() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(_collectionName).get();

      if (querySnapshot.docs.isNotEmpty) {
        List<User> tempUsers = [];
        for (var doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            try {
              User user = User.fromFirestore(data, doc.id);
              tempUsers.add(user);
            } catch (e) {
              // Pertimbangkan logging error yang lebih formal di production
              // misalnya menggunakan package logging atau Firebase Crashlytics
              // print("Error mapping document ${doc.id}: $e");
            }
          }
        }

        if (tempUsers.isNotEmpty) {
          tempUsers.sort(
            (a, b) =>
                a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase()),
          );
          setState(() {
            _users = tempUsers;
            _filteredUsers = _users;
            _isLoading = false;
            _errorMessage = '';
          });
        } else {
          setState(() {
            _errorMessage =
                'Tidak ada data kontak valid yang dapat ditampilkan. Periksa format data di Firestore.';
            _isLoading = false;
            _users = [];
            _filteredUsers = [];
          });
        }
      } else {
        setState(() {
          _errorMessage =
              "Tidak ada data kontak ditemukan di database untuk koleksi '$_collectionName'.";
          _isLoading = false;
          _users = [];
          _filteredUsers = [];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Terjadi kesalahan saat mengambil data: $e. Periksa koneksi dan konfigurasi Firebase.';
        _isLoading = false;
        _users = [];
        _filteredUsers = [];
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body:
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
              : RefreshIndicator(
                onRefresh: _fetchUsersFromFirestore,
                child:
                    _filteredUsers.isEmpty && !_isLoading
                        ? Center(
                          child: Text(
                            _searchController.text.isEmpty
                                ? 'Tidak ada kontak untuk ditampilkan.'
                                : 'Tidak ada hasil untuk "${_searchController.text}".',
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                        : ListView.builder(
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
      floatingActionButton:
          _showFab
              ? FloatingActionButton(
                onPressed:
                    _navigateToAddContactPage, // Menggunakan fungsi navigasi
                tooltip: 'Tambah Kontak',
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

class _HomeBottomAppBar extends StatelessWidget {
  const _HomeBottomAppBar({this.shape = const CircularNotchedRectangle()});

  final NotchedShape? shape;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isLightMode = Theme.of(context).brightness == Brightness.light;
    Color bottomAppBarColor = colorScheme.surface;
    Color transparentBottomAppBarColor = bottomAppBarColor.withOpacity(0.9);

    return BottomAppBar(
      shape: shape,
      color: transparentBottomAppBarColor,
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
                  // Mungkin tidak perlu aksi jika sudah di halaman ini
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
