import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';

class VendorHomeScreen extends StatelessWidget {
  const VendorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    if (currentUser == null) return const Center(child: Text('Silakan login'));

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Halo, Vendor!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Pantau perkembangan bisnismu hari ini', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                  const CircleAvatar(radius: 24, backgroundColor: Color(0xFFFDE8EE), child: Icon(Icons.storefront, color: AppColors.primaryPink))
                ],
              ),
              const SizedBox(height: 30),

              // STATISTIK DINAMIS
              StreamBuilder<QuerySnapshot>(
                // Membaca seluruh pesanan toko ini
                stream: FirebaseFirestore.instance.collection('orders').where('vendorId', isEqualTo: currentUser.uid).snapshots(),
                builder: (context, snapshot) {
                  int totalPendapatan = 0;
                  int pesananAktif = 0;

                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      var data = doc.data() as Map<String, dynamic>;
                      String status = data['status'] ?? '';
                      
                      if (status == 'Selesai') {
                        // Jika selesai, masuk ke pendapatan
                        totalPendapatan += (data['totalPrice'] ?? 0) as int;
                      } else if (status == 'Menunggu' || status == 'Diproses') {
                        // Jika belum selesai, masuk ke pesanan aktif
                        pesananAktif++;
                      }
                    }
                  }

                  return Column(
                    children: [
                      // KARTU PENDAPATAN
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFE56B8B), Color(0xFFD65A7A)]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: const Color(0xFFE56B8B).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Pendapatan', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(currencyFormat.format(totalPendapatan), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                              child: const Text('Diperbarui secara real-time', style: TextStyle(color: Colors.white, fontSize: 10)),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // KARTU PESANAN AKTIF
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.receipt_long, color: Colors.blue),
                                  const SizedBox(height: 12),
                                  Text(pesananAktif.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  const Text('Pesanan Aktif', style: TextStyle(color: Colors.black54, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber),
                                  const SizedBox(height: 12),
                                  const Text('0', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  const Text('Total Ulasan', style: TextStyle(color: Colors.black54, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              ),

              const SizedBox(height: 30),
              const Text('Aktivitas Toko', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Text('Semua sistem berjalan lancar.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}