import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final int totalPrice; // Menerima harga asli

  const PaymentScreen({super.key, required this.totalPrice});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPayment = 0; 

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Pembayaran', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFFDE8EE), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const Text('Total Pembayaran', style: TextStyle(color: Colors.black54, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(currencyFormat.format(widget.totalPrice), style: const TextStyle(color: Color(0xFFE56B8B), fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('Pilih Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            _buildPaymentOption(0, Icons.account_balance, 'Transfer Bank (Virtual Account)'),
            _buildPaymentOption(1, Icons.account_balance_wallet, 'E-Wallet (Gopay, OVO, Dana)'),
            _buildPaymentOption(2, Icons.credit_card, 'Kartu Kredit / Debit'),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20), color: Colors.white,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE56B8B), padding: const EdgeInsets.symmetric(vertical: 16), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PaymentSuccessScreen()));
          },
          child: const Text('Bayar Sekarang', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(int index, IconData icon, String title) {
    bool isSelected = _selectedPayment == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isSelected ? AppColors.primaryPink.withValues(alpha :0.1) : Colors.white, border: Border.all(color: isSelected ? const Color(0xFFE56B8B) : Colors.grey.shade300, width: isSelected ? 2 : 1), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFFE56B8B) : Colors.black54),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFFE56B8B)),
          ],
        ),
      ),
    );
  }
}