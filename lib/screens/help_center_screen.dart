import 'package:flutter/material.dart';
import '../utils/colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Pusat Bantuan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Pertanyaan Umum (FAQ)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          _buildFAQItem('Bagaimana cara memesan vendor?', 'Pilih vendor dari menu beranda, klik Pesan Sekarang, tentukan tanggal, lalu lakukan pembayaran.'),
          _buildFAQItem('Apakah saya bisa membatalkan pesanan?', 'Pesanan dapat dibatalkan maksimal H-7 sebelum acara. Pengembalian dana akan dipotong biaya administrasi.'),
          _buildFAQItem('Metode pembayaran apa saja yang didukung?', 'Kami mendukung Transfer Bank, E-Wallet (Gopay, OVO, Dana), dan Kartu Kredit.'),
          _buildFAQItem('Bagaimana cara menghubungi vendor?', 'Anda dapat menggunakan fitur Chat yang ada di dalam aplikasi setelah menekan ikon pesan di detail vendor.'),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.headset_mic, color: Colors.black87),
            label: const Text('Hubungi Customer Service', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuka layanan WhatsApp Customer Service...')));
            },
          )
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer, style: const TextStyle(color: Colors.black54, height: 1.5)),
          ),
        ],
      ),
    );
  }
}