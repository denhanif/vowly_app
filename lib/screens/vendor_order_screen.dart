import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';

class VendorOrderScreen extends StatefulWidget {
  const VendorOrderScreen({super.key});

  @override
  State<VendorOrderScreen> createState() => _VendorOrderScreenState();
}

class _VendorOrderScreenState extends State<VendorOrderScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // Fungsi untuk mengubah status pesanan di Firestore
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pesanan $newStatus!'), backgroundColor: newStatus == 'Ditolak' ? Colors.red : Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memperbarui status'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundWhite,
          elevation: 0,
          title: const Text('Manajemen Pesanan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            labelColor: AppColors.primaryPink,
            unselectedLabelColor: Colors.black54,
            indicatorColor: AppColors.primaryPink,
            tabs: [
              Tab(text: 'Pesanan Baru'),
              Tab(text: 'Diproses'),
              Tab(text: 'Riwayat'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(['Menunggu']), // Tab 1: Pesanan Baru
            _buildOrderList(['Diproses']), // Tab 2: Sedang Dikerjakan
            _buildOrderList(['Selesai', 'Ditolak']), // Tab 3: Selesai / Batal
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<String> statusFilter) {
    if (currentUser == null) return const Center(child: Text('Silakan login'));

    return StreamBuilder<QuerySnapshot>(
      // Mengambil pesanan yang vendorId-nya sama dengan akun ini, dan statusnya sesuai tab
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('vendorId', isEqualTo: currentUser!.uid)
          .where('status', whereIn: statusFilter)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text('Tidak ada pesanan di kategori ini.', style: TextStyle(color: Colors.grey.shade600)));

        var orders = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            var order = orders[index].data() as Map<String, dynamic>;
            String orderId = orders[index].id;
            String status = order['status'] ?? 'Menunggu';

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
                        Expanded(child: Text(order['packageName'] ?? 'Paket Layanan', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: _getStatusColor(status).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(status, style: TextStyle(color: _getStatusColor(status), fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(Icons.person_outline, 'Klien', order['customerName'] ?? 'Klien Vowly'),
                    _buildDetailRow(Icons.calendar_today, 'Tanggal Acara', order['eventDate'] ?? '-'),
                    _buildDetailRow(Icons.payments_outlined, 'Pendapatan', currencyFormat.format(order['totalPrice'] ?? 0)),
                    if (order['notes'] != null && order['notes'].toString().isNotEmpty)
                      _buildDetailRow(Icons.notes, 'Catatan', order['notes']),
                    
                    const SizedBox(height: 16),
                    
                    // --- TOMBOL AKSI BERDASARKAN STATUS ---
                    if (status == 'Menunggu')
                      Row(
                        children: [
                          Expanded(child: OutlinedButton(onPressed: () => _updateOrderStatus(orderId, 'Ditolak'), style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)), child: const Text('Tolak'))),
                          const SizedBox(width: 12),
                          Expanded(child: ElevatedButton(onPressed: () => _updateOrderStatus(orderId, 'Diproses'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text('Terima', style: TextStyle(color: Colors.white)))),
                        ],
                      ),
                      
                    if (status == 'Diproses')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _updateOrderStatus(orderId, 'Selesai'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Selesaikan Pesanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(color: Colors.black54)),
                  TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Menunggu': return Colors.orange;
      case 'Diproses': return Colors.blue;
      case 'Selesai': return Colors.green;
      case 'Ditolak': return Colors.red;
      default: return Colors.grey;
    }
  }
}