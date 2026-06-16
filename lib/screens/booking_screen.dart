import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final String vendorId;
  final String vendorName;
  final String packageId;
  final Map<String, dynamic> packageData;

  const BookingScreen({super.key, required this.vendorId, required this.vendorName, required this.packageId, required this.packageData});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  Future<void> _createOrder() async {
    if (_dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih tanggal acara terlebih dahulu!'), backgroundColor: Colors.red));
      return;
    }

    setState(() { _isLoading = true; });
    User? currentUser = FirebaseAuth.instance.currentUser;

    try {
      // Ambil nama klien
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      String customerName = (userDoc.data() as Map<String, dynamic>)['name'] ?? 'Klien Vowly';

      // Simpan ke collection orders
      await FirebaseFirestore.instance.collection('orders').add({
        'customerId': currentUser.uid,
        'customerName': customerName,
        'vendorId': widget.vendorId,
        'packageId': widget.packageId,
        'packageName': widget.packageData['name'],
        'totalPrice': widget.packageData['price'],
        'eventDate': _dateController.text,
        'notes': _notesController.text.trim(),
        'status': 'Menunggu', // Status awal
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Pindah ke layar pembayaran
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PaymentScreen(totalPrice: widget.packageData['price'])));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuat pesanan'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Buat Pesanan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                children: [
                  Container(width: 60, height: 60, color: Colors.grey.shade300, child: const Icon(Icons.store, color: Colors.white)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.vendorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(widget.packageData['name'], style: const TextStyle(color: Color(0xFFE56B8B), fontWeight: FontWeight.w500)),
                        Text(currencyFormat.format(widget.packageData['price']), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('Tanggal Acara', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController, readOnly: true, onTap: () => _selectDate(context),
              decoration: InputDecoration(hintText: 'Pilih Tanggal', suffixIcon: const Icon(Icons.calendar_today, color: Colors.black54), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 20),
            const Text('Catatan Tambahan', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController, maxLines: 4,
              decoration: InputDecoration(hintText: 'Tuliskan request khusus...', filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20), color: Colors.white,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE56B8B), padding: const EdgeInsets.symmetric(vertical: 16), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: _isLoading ? null : _createOrder,
          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Lanjut Pembayaran', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}