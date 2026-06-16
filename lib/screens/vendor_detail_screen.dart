import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import 'booking_screen.dart'; // Import halaman pemesanan

class VendorDetailScreen extends StatelessWidget {
  final String? vendorId;
  final String? vendorName;

  // Constructor menerima ID dan Nama dari layar Beranda
  const VendorDetailScreen({super.key, this.vendorId, this.vendorName});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: AppColors.primaryPink,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(vendorName ?? 'Detail Vendor', style: const TextStyle(fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black54, blurRadius: 10)])),
              background: Container(color: Colors.grey.shade400, child: const Icon(Icons.store, size: 100, color: Colors.white)),
            ),
            leading: IconButton(icon: const CircleAvatar(backgroundColor: Colors.white54, child: Icon(Icons.arrow_back, color: Colors.black)), onPressed: () => Navigator.pop(context)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Daftar Layanan & Paket', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Icon(Icons.verified, color: Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Mengambil Paket milik Vendor tersebut
                  if (vendorId != null)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('packages').where('vendorId', isEqualTo: vendorId).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('Vendor ini belum memiliki paket.', style: TextStyle(color: Colors.black54))));

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var package = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                            String packageId = snapshot.data!.docs[index].id;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(package['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    const SizedBox(height: 8),
                                    Text(package['description'] ?? '', style: const TextStyle(color: Colors.black54, height: 1.5)),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(currencyFormat.format(package['price'] ?? 0), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE56B8B), fontSize: 16)),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                          onPressed: () {
                                            // Lanjut ke Pemesanan membawa data paket
                                            Navigator.push(context, MaterialPageRoute(
                                              builder: (context) => BookingScreen(
                                                vendorId: vendorId!,
                                                vendorName: vendorName!,
                                                packageId: packageId,
                                                packageData: package,
                                              )
                                            ));
                                          },
                                          child: const Text('Pesan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    )
                  else
                    const Text('Data vendor tidak valid.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}