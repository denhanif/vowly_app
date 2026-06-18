import 'package:flutter/material.dart';
import '../utils/colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Notifikasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildNotifItem(Icons.shopping_bag_outlined, 'Pesanan Baru', 'Anda menerima pesanan baru dari calon pengantin.', '5 menit lalu'),
          const Divider(height: 30, color: Colors.black12),
          _buildNotifItem(Icons.payments_outlined, 'Pembayaran Berhasil', 'Dana sebesar Rp 5.000.000 berhasil diterima.', '1 jam lalu'),
          const Divider(height: 30, color: Colors.black12),
          _buildNotifItem(Icons.chat_bubble_outline, 'Pesan Baru', 'Anda menerima pesan dari pelanggan.', 'Kemarin'),
        ],
      ),
    );
  }

  Widget _buildNotifItem(IconData icon, String title, String desc, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.primaryPink.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.primaryPink),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.5)),
              const SizedBox(height: 8),
              Text(time, style: const TextStyle(color: Colors.black38, fontSize: 11)),
            ],
          ),
        )
      ],
    );
  }
}