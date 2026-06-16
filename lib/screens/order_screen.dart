import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        title: const Text('Pesanan Saya', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false, // Menghilangkan tombol back karena ini adalah tab utama
      ),
      body: currentUser == null
          ? const Center(child: Text('Silakan login terlebih dahulu'))
          : StreamBuilder<QuerySnapshot>(
              // Hanya mengambil data pesanan milik Klien yang sedang login
              stream: FirebaseFirestore.instance.collection('orders').where('customerId', isEqualTo: currentUser.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Anda belum memiliki pesanan.', style: TextStyle(color: Colors.black54)));
                }

                // Urutkan data berdasarkan waktu terbaru (karena Firestore butuh index manual jika menggunakan orderBy + where)
                var orders = snapshot.data!.docs;
                orders.sort((a, b) {
                  var aData = a.data() as Map<String, dynamic>;
                  var bData = b.data() as Map<String, dynamic>;
                  Timestamp? aTime = aData['createdAt'] as Timestamp?;
                  Timestamp? bTime = bData['createdAt'] as Timestamp?;
                  if (aTime == null || bTime == null) return 0;
                  return bTime.compareTo(aTime); 
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var order = orders[index].data() as Map<String, dynamic>;
                    String status = order['status'] ?? 'Menunggu';
                    
                    // Menentukan warna badge status
                    Color statusColor = Colors.orange;
                    if (status == 'Diproses') statusColor = Colors.blue;
                    else if (status == 'Selesai') statusColor = Colors.green;
                    else if (status == 'Ditolak') statusColor = Colors.red;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(order['vendorName'] ?? 'Vendor Vowly', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                  child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                )
                              ],
                            ),
                            const Divider(height: 24),
                            Text(order['packageName'] ?? 'Paket Layanan', style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('Tanggal Acara: ${order['eventDate'] ?? '-'}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Pembayaran', style: TextStyle(color: Colors.black54, fontSize: 12)),
                                Text(currencyFormat.format(order['totalPrice'] ?? 0), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE56B8B), fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}