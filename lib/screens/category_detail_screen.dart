import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';
import 'vendor_detail_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;

  const CategoryDetailScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(categoryName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // MENGAMBIL DATA BERDASARKAN FILTER KATEGORI
        stream: FirebaseFirestore.instance.collection('users')
          .where('role', isEqualTo: 'vendor')
          .where('category', isEqualTo: categoryName)
          .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Belum ada vendor di kategori $categoryName.', style: const TextStyle(color: Colors.black54)),
                ],
              )
            );
          }

          final vendors = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 16, mainAxisSpacing: 16),
            itemCount: vendors.length,
            itemBuilder: (context, index) {
              var vendorData = vendors[index].data() as Map<String, dynamic>? ?? {};
              String vendorId = vendors[index].id;
              
              String imageUrl = vendorData['imageUrl'] ?? 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=500&auto=format&fit=crop';
              String category = vendorData['category'] ?? categoryName;

              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VendorDetailScreen(vendorId: vendorId, vendorName: vendorData['name'] ?? 'Vendor'))),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                  ),
                  child: Stack(
                    children: [
                      Align(alignment: Alignment.bottomCenter, child: Container(height: 80, decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)), gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.8), Colors.transparent])))),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(4)), child: Text(category, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFE56B8B)))),
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
    );
  }
}