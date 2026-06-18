import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';
import 'vendor_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        // --- KOLOM PENCARIAN DI APPBAR ---
        title: TextField(
          controller: _searchController,
          autofocus: true, // Otomatis memunculkan keyboard saat halaman dibuka
          decoration: const InputDecoration(
            hintText: 'Cari nama vendor atau kategori...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black38),
          ),
          style: const TextStyle(fontSize: 16),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase(); // Ubah ke huruf kecil semua agar mudah difilter
            });
          },
        ),
        actions: [
          // Tombol silang (X) untuk menghapus teks pencarian dengan cepat
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.black54),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            )
        ],
      ),
      body: _searchQuery.isEmpty
          // --- JIKA KOSONG, TAMPILKAN ILUSTRASI PENCARIAN ---
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 80, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  const Text('Ketik untuk mulai mencari...', style: TextStyle(color: Colors.black54, fontSize: 16)),
                ],
              ),
            )
          // --- JIKA ADA TEKS, MULAI CARI DI DATABASE ---
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'vendor').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Belum ada data vendor.', style: TextStyle(color: Colors.black54)));
                }

                // LOGIKA FILTER PINTAR (Mencari di Nama Vendor ATAU Kategori)
                var filteredDocs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String name = (data['name'] ?? '').toString().toLowerCase();
                  String category = (data['category'] ?? '').toString().toLowerCase();
                  
                  // Akan memunculkan hasil jika nama ATAU kategori mengandung kata yang diketik
                  return name.contains(_searchQuery) || category.contains(_searchQuery);
                }).toList();

                // Jika setelah difilter hasilnya kosong
                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text('Tidak ada hasil untuk "$_searchQuery"', style: const TextStyle(color: Colors.black54, fontSize: 16)),
                  );
                }

                // Jika ada hasil, tampilkan daftarnya
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var vendorData = filteredDocs[index].data() as Map<String, dynamic>;
                    String vendorId = filteredDocs[index].id;
                    String imageUrl = vendorData['imageUrl'] ?? 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=500&auto=format&fit=crop';
                    String category = vendorData['category'] ?? 'Event Organizer';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(imageUrl),
                        ),
                        title: Text(vendorData['name'] ?? 'Vendor', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(category, style: const TextStyle(color: AppColors.primaryPink, fontSize: 12, fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.black38),
                        onTap: () {
                          // Klik hasil pencarian -> Masuk ke profil vendor tersebut
                          Navigator.push(context, MaterialPageRoute(builder: (context) => VendorDetailScreen(
                            vendorId: vendorId,
                            vendorName: vendorData['name'] ?? 'Vendor',
                          )));
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}