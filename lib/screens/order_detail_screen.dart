import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'review_screen.dart'; // Import layar ulasan

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detail Pesanan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Acara Selesai', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Terima kasih telah menggunakan layanan vendor ini.', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('Informasi Layanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(width: 50, height: 50, color: Colors.grey.shade300, child: const Icon(Icons.store)),
              title: const Text('Nama Vendor EO', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Paket Silver - Rp 15.000.000'),
            ),
            const Divider(height: 30),
            
            const Text('Detail Acara', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildDetailRow('Tanggal', '12 November 2026'),
            _buildDetailRow('Lokasi', 'Surakarta'),
            const Divider(height: 30),

            const Text('Rincian Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildDetailRow('Harga Paket', 'Rp 15.000.000'),
            _buildDetailRow('Biaya Layanan', 'Rp 50.000'),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Rp 15.050.000', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE56B8B), fontSize: 16)),
              ],
            ),
            const SizedBox(height: 40),
            
            // Tombol Beri Ulasan
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewScreen()));
              },
              child: const Text('Beri Ulasan Vendor', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}