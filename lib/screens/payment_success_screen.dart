import 'package:flutter/material.dart';
import '../utils/colors.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(radius: 50, backgroundColor: Colors.green, child: Icon(Icons.check, size: 50, color: Colors.white)),
                const SizedBox(height: 24),
                const Text('Pembayaran Berhasil!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('Pesanan Anda telah diteruskan ke Vendor. Silakan pantau status pesanan Anda di menu Pesanan.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, height: 1.5)),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () {
                    // Kembali ke Beranda Utama dan menghapus tumpukan history layar sebelumnya
                    Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
                  },
                  child: const Text('Kembali ke Beranda', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}