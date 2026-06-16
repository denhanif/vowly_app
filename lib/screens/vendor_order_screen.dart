import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';

class VendorOrderScreen extends StatelessWidget {
  const VendorOrderScreen({super.key});

  void _updateOrderStatus(String orderId, String newStatus, BuildContext context) {
    FirebaseFirestore.instance.collection('orders').doc(orderId).update({'status': newStatus}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pesanan $newStatus!'), backgroundColor: newStatus == 'Ditolak' ? Colors.red : Colors.green));
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundWhite,
          elevation: 0,
          title: const Text('Kelola Pesanan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            labelColor: Color(0xFFE56B8B),
            unselectedLabelColor: Colors.black54,
            indicatorColor: Color(0xFFE56B8B),
            tabs: [Tab(text: 'Baru'), Tab(text: 'Diproses'), Tab(text: 'Selesai')],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').where('vendorId', isEqualTo: currentUserId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
            
            List<QueryDocumentSnapshot> allOrders = snapshot.hasData ? snapshot.data!.docs : [];
            
            // Memisahkan pesanan berdasarkan status
            List<QueryDocumentSnapshot> newOrders = allOrders.where((doc) => doc['status'] == 'Menunggu').toList();
            List<QueryDocumentSnapshot> processOrders = allOrders.where((doc) => doc['status'] == 'Diproses').toList();
            List<QueryDocumentSnapshot> completedOrders = allOrders.where((doc) => doc['status'] == 'Selesai').toList();

            return TabBarView(
              children: [
                _buildOrderList(newOrders, true, context), // Tab Baru (Bisa Terima/Tolak)
                _buildOrderList(processOrders, false, context), // Tab Diproses
                _buildOrderList(completedOrders, false, context), // Tab Selesai
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<QueryDocumentSnapshot> orders, bool showActions, BuildContext context) {
    if (orders.isEmpty) {
      return const Center(child: Text('Belum ada pesanan di kategori ini.', style: TextStyle(color: Colors.black54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        var order = orders[index].data() as Map<String, dynamic>;
        String docId = orders[index].id;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ID: ${docId.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                    Text('Rp ${order['totalPrice'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE56B8B))),
                  ],
                ),
                const Divider(height: 24),
                Text(order['packageName'] ?? 'Paket', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Klien: ${order['customerName'] ?? 'Anonim'}\nTanggal: ${order['eventDate'] ?? '-'}', style: const TextStyle(color: Colors.black87, height: 1.5)),
                
                if (showActions) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () => _updateOrderStatus(docId, 'Ditolak', context), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)), child: const Text('Tolak', style: TextStyle(color: Colors.red)))),
                      const SizedBox(width: 12),
                      Expanded(child: ElevatedButton(onPressed: () => _updateOrderStatus(docId, 'Diproses', context), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('Terima', style: TextStyle(color: Colors.white)))),
                    ],
                  )
                ] else ...[
                   const SizedBox(height: 16),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                     decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                     child: Text('Status: ${order['status']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                   )
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}