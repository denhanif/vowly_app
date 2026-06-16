import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Untuk format Rupiah
import '../utils/colors.dart';

class VendorHomeScreen extends StatelessWidget {
  const VendorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    // Format mata uang Rupiah
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SAPAAN NAMA
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).get(),
                builder: (context, snapshot) {
                  String vendorName = 'Vendor';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    vendorName = (snapshot.data!.data() as Map<String, dynamic>)['name'] ?? 'Vendor';
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Halo, $vendorName!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            const Text('Pantau perkembangan bisnismu hari ini', style: TextStyle(color: Colors.black54, fontSize: 14)),
                          ],
                        ),
                      ),
                      const CircleAvatar(backgroundColor: Color(0xFFFDE8EE), child: Icon(Icons.store, color: Color(0xFFE56B8B))),
                    ],
                  );
                }
              ),
              const SizedBox(height: 30),
              
              // 2. STATISTIK DINAMIS (Mengambil dari tabel 'orders')
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('orders').where('vendorId', isEqualTo: currentUser?.uid).snapshots(),
                builder: (context, snapshot) {
                  int totalPendapatan = 0;
                  int pesananAktif = 0;

                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      var order = doc.data() as Map<String, dynamic>;
                      // Jika pesanan berstatus Selesai, tambahkan harganya ke pendapatan
                      if (order['status'] == 'Selesai') {
                        totalPendapatan += (order['totalPrice'] ?? 0) as int;
                      }
                      // Jika pesanan masih masuk atau diproses, hitung sebagai aktif
                      if (order['status'] == 'Menunggu' || order['status'] == 'Diproses') {
                        pesananAktif++;
                      }
                    }
                  }

                  return Column(
                    children: [
                      // Kartu Pendapatan
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFE56B8B), Color(0xFFD65A7A)]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFFE56B8B).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Pendapatan', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(currencyFormat.format(totalPendapatan), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: const Text('Diperbarui secara real-time', style: TextStyle(color: Colors.white, fontSize: 10)))])
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Grid Pesanan Aktif
                      Row(
                        children: [
                          Expanded(child: _buildStatCard('Pesanan Aktif', pesananAktif.toString(), Icons.receipt_long, Colors.blue)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildStatCard('Total Ulasan', '0', Icons.star, Colors.amber)), // Ulasan bisa dikerjakan nanti
                        ],
                      ),
                    ],
                  );
                }
              ),
              const SizedBox(height: 30),
              
              const Text('Aktivitas Toko', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Center(child: Text('Siap menerima pesanan pertama Anda!', style: TextStyle(color: Colors.black54)))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      ),
    );
  }
}