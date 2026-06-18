import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';

class VendorRevenueScreen extends StatelessWidget {
  const VendorRevenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        title: const Text('Pendapatan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: currentUser == null
        ? const Center(child: Text('Silakan login terlebih dahulu'))
        : StreamBuilder<QuerySnapshot>(
            // Hanya mengambil pesanan milik Vendor ini yang statusnya 'Selesai'
            stream: FirebaseFirestore.instance.collection('orders')
              .where('vendorId', isEqualTo: currentUser.uid)
              .where('status', isEqualTo: 'Selesai')
              .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
              
              // Menghitung total pendapatan
              int totalRevenue = 0;
              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  totalRevenue += (data['totalPrice'] ?? 0) as int;
                }
              }

              var orders = snapshot.hasData ? snapshot.data!.docs : [];

              return Column(
                children: [
                  // --- KARTU SALDO ---
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFE56B8B), Color(0xFFD65A7A)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0xFFE56B8B).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saldo Dapat Ditarik', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(currencyFormat.format(totalRevenue), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryPink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            onPressed: () {
                              if (totalRevenue > 0) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permintaan penarikan dana sedang diproses!'), backgroundColor: Colors.green));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saldo Anda masih kosong.'), backgroundColor: Colors.red));
                              }
                            },
                            child: const Text('Tarik Dana ke Rekening', style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        )
                      ],
                    ),
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Align(alignment: Alignment.centerLeft, child: Text('Riwayat Transaksi (Selesai)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  ),
                  const SizedBox(height: 10),

                  // --- DAFTAR TRANSAKSI ---
                  Expanded(
                    child: orders.isEmpty 
                      ? const Center(child: Text('Belum ada pesanan yang selesai.', style: TextStyle(color: Colors.black54)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            var order = orders[index].data() as Map<String, dynamic>;
                            return Card(
                              elevation: 0,
                              color: Colors.grey.shade50,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                              child: ListTile(
                                leading: CircleAvatar(backgroundColor: Colors.green.shade50, child: const Icon(Icons.check, color: Colors.green)),
                                title: Text(order['customerName'] ?? 'Klien', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text(order['packageName'] ?? '', style: const TextStyle(fontSize: 12)),
                                trailing: Text('+ ${currencyFormat.format(order['totalPrice'] ?? 0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              ),
                            );
                          }
                        )
                  )
                ],
              );
            }
          )
    );
  }
}