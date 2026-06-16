import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';
import 'add_package_screen.dart';
import 'edit_package_screen.dart'; // <-- IMPORT BARU

class VendorPackageScreen extends StatelessWidget {
  const VendorPackageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        title: const Text('Layanan Saya', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('packages').where('vendorId', isEqualTo: currentUserId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('Anda belum menambahkan layanan/paket apapun.', style: TextStyle(color: Colors.black54)));

          final packages = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: packages.length,
            itemBuilder: (context, index) {
              var package = packages[index].data() as Map<String, dynamic>;
              String docId = packages[index].id;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: const BorderRadius.horizontal(left: Radius.circular(12))), child: const Icon(Icons.image, color: Colors.white, size: 40)),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(package['name'] ?? 'Nama Paket', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                Row(
                                  children: [
                                    // --- TOMBOL EDIT BARU ---
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18, color: Colors.blue), 
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => EditPackageScreen(packageId: docId, currentData: package)
                                        ));
                                      }, 
                                      padding: EdgeInsets.zero, constraints: const BoxConstraints()
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red), 
                                      onPressed: () => FirebaseFirestore.instance.collection('packages').doc(docId).delete(), 
                                      padding: EdgeInsets.zero, constraints: const BoxConstraints()
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(package['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                            const SizedBox(height: 8),
                            Text('Rp ${package['price']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE56B8B))),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE56B8B),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPackageScreen())),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Layanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}