import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';
import 'notification_screen.dart';
import 'search_screen.dart'; 
import 'vendor_list_screen.dart'; 
import 'category_detail_screen.dart'; 
import 'vendor_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBannerIndex = 0;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.camera_alt, 'label': 'Fotografer'},
    {'icon': Icons.local_florist, 'label': 'Florist'},
    {'icon': Icons.face_retouching_natural, 'label': 'Makeup Artist'},
    {'icon': Icons.celebration, 'label': 'Dekorasi'},
    {'icon': Icons.restaurant, 'label': 'Catering'},
    {'icon': Icons.mail, 'label': 'Undangan'},
    {'icon': Icons.speaker, 'label': 'Musisi'},
    {'icon': Icons.checkroom, 'label': 'Desainer'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildSearchBar(context),
              const SizedBox(height: 24),
              _buildPromoCarousel(),
              const SizedBox(height: 30),
              _buildCategorySection(context),
              const SizedBox(height: 30),
              _buildVendorSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Jaring pengaman 1: Jika belum login, jangan query ke database
    if (currentUser == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text('Halo, Klien', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          IconButton(icon: const Icon(Icons.notifications_none, color: AppColors.primaryPink, size: 30), onPressed: () {}),
        ],
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get(),
      builder: (context, snapshot) {
        String userName = 'Klien';
        
        if (snapshot.hasData && snapshot.data!.exists) {
          // Jaring pengaman 2: Gunakan cast nullable (Map?) agar tidak crash jika dokumen kosong
          var userData = snapshot.data!.data() as Map<String, dynamic>?;
          if (userData != null) {
            userName = userData['name'] ?? 'Klien';
          }
        }
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppColors.primaryPink, size: 30),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Halo,', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        Text(userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.notifications_none, color: AppColors.primaryPink, size: 30), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()))),
          ],
        );
      }
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.grey.shade300)),
        child: Row(children: const [Icon(Icons.search, color: Colors.black38), SizedBox(width: 10), Text('Cari Vendor, Paket, atau Layanan', style: TextStyle(color: Colors.black38, fontSize: 14))]),
      ),
    );
  }

  Widget _buildPromoCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            itemCount: 3,
            onPageChanged: (index) => setState(() => _currentBannerIndex = index),
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(color: const Color(0xFFFDE8EE), borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Promo Spesial', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 4),
                    const Text('Diskon hingga 20%', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 12),
                    ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE56B8B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), minimumSize: Size.zero), onPressed: () {}, child: const Text('Lihat Promo', style: TextStyle(fontSize: 12, color: Colors.white)))
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (index) => Container(margin: const EdgeInsets.symmetric(horizontal: 3), width: _currentBannerIndex == index ? 16 : 6, height: 6, decoration: BoxDecoration(color: _currentBannerIndex == index ? const Color(0xFFE56B8B) : Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))))
      ],
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Kategori', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () => Navigator.pushNamed(context, '/categories'), child: const Text('Lihat Semua', style: TextStyle(color: Color(0xFFE56B8B), fontWeight: FontWeight.bold))),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(), shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.8, crossAxisSpacing: 10, mainAxisSpacing: 15),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryDetailScreen(categoryName: categories[index]['label']))),
              child: Column(
                children: [
                  Container(height: 60, width: 60, decoration: const BoxDecoration(color: Color(0xFFF7EBEF), shape: BoxShape.circle), child: Icon(categories[index]['icon'], color: Colors.black87, size: 28)),
                  const SizedBox(height: 8),
                  Text(categories[index]['label'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVendorSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Rekomendasi Vendor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VendorListScreen())), child: const Text('Lihat Semua', style: TextStyle(color: Color(0xFFE56B8B), fontWeight: FontWeight.bold))),
          ],
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'vendor').limit(4).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('Belum ada vendor yang bergabung.'));

            final vendors = snapshot.data!.docs;

            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(), shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1, crossAxisSpacing: 16, mainAxisSpacing: 16),
              itemCount: vendors.length,
              itemBuilder: (context, index) {
                // Jaring pengaman 3: Tambahkan ?? {} agar tidak crash jika dokumen vendor kosong
                var vendorData = vendors[index].data() as Map<String, dynamic>? ?? {};
                String vendorId = vendors[index].id;

                return GestureDetector(
                  onTap: () { 
                    Navigator.push(context, MaterialPageRoute(builder: (context) => VendorDetailScreen(vendorId: vendorId, vendorName: vendorData['name'] ?? 'Vendor'))); 
                  },
                  child: Container(
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
                    child: Stack(
                      children: [
                        Align(alignment: Alignment.bottomCenter, child: Container(height: 60, decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)), gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.8), Colors.transparent])))),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(4)), child: const Text('Event Organizer', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFE56B8B)))),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(vendorData['name'] ?? 'Vendor', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Row(children: const [Icon(Icons.star, color: Colors.amber, size: 14), SizedBox(width: 4), Text('Baru', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))])
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        ),
      ],
    );
  }
}