import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import 'payment_success_screen.dart'; // Pastikan file ini ada (kodenya di bawah)

class PaymentScreen extends StatefulWidget {
  // Menerima data dari halaman Booking sebelumnya
  final String vendorId;
  final String packageId;
  final String packageName;
  final int totalPrice;
  final String eventDate;

  const PaymentScreen({
    super.key,
    required this.vendorId,
    required this.packageId,
    required this.packageName,
    required this.totalPrice,
    required this.eventDate,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'Transfer Bank (Virtual Account)';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'icon': Icons.account_balance, 'label': 'Transfer Bank (Virtual Account)'},
    {'icon': Icons.account_balance_wallet, 'label': 'E-Wallet (Gopay, OVO, Dana)'},
    {'icon': Icons.credit_card, 'label': 'Kartu Kredit / Debit'},
  ];

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true; // Menampilkan efek loading berputar di tombol
    });

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("User belum login");

      // 1. Ambil nama klien yang sedang login
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      String customerName = (userDoc.data() as Map<String, dynamic>?)?['name'] ?? 'Klien Vowly';

      // 2. Simulasi loading menghubungi pihak Bank (Tunggu 3 detik)
      await Future.delayed(const Duration(seconds: 3));

      // 3. Masukkan pesanan ke database Firestore agar terbaca oleh Vendor
      await FirebaseFirestore.instance.collection('orders').add({
        'vendorId': widget.vendorId,
        'customerId': currentUser.uid,
        'customerName': customerName,
        'packageId': widget.packageId,
        'packageName': widget.packageName,
        'totalPrice': widget.totalPrice,
        'eventDate': widget.eventDate,
        'paymentMethod': _selectedMethod,
        'status': 'Menunggu', // Status awal agar vendor bisa menerima/menolak
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 4. Jika berhasil, pindah ke layar Sukses
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PaymentSuccessScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pembayaran gagal: $e'), backgroundColor: Colors.red));
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Pembayaran', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- KARTU TOTAL PEMBAYARAN ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(color: const Color(0xFFFDE8EE), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Text('Total Pembayaran', style: TextStyle(color: Colors.black54, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(widget.totalPrice),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryPink),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text('Pilih Metode Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // --- PILIHAN METODE PEMBAYARAN INTERAKTIF ---
            Expanded(
              child: ListView.builder(
                itemCount: _paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = _paymentMethods[index];
                  final isSelected = _selectedMethod == method['label'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMethod = method['label']; // Mengubah status saat diklik
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? AppColors.primaryPink : Colors.grey.shade300, width: isSelected ? 2 : 1),
                      ),
                      child: Row(
                        children: [
                          Icon(method['icon'], color: isSelected ? AppColors.primaryPink : Colors.grey.shade600),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              method['label'],
                              style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: Colors.black87),
                            ),
                          ),
                          if (isSelected) const Icon(Icons.check_circle, color: AppColors.primaryPink),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // --- TOMBOL BAYAR SEKARANG DENGAN EFEK LOADING ---
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: _isProcessing ? null : _processPayment, // Nonaktifkan tombol saat loading
                child: _isProcessing
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Bayar Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}