import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import 'payment_screen.dart'; // <-- Import halaman pembayaran

class BookingScreen extends StatefulWidget {
  final String vendorId;
  final String vendorName;
  final String packageId;
  final Map<String, dynamic> packageData;

  const BookingScreen({
    super.key,
    required this.vendorId,
    required this.vendorName,
    required this.packageId,
    required this.packageData,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  final TextEditingController _notesController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)), // Default minggu depan
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPink,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    int price = widget.packageData['price'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Detail Pesanan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- INFO VENDOR & PAKET ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.store, color: AppColors.primaryPink),
                      const SizedBox(width: 8),
                      Text(widget.vendorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(widget.packageData['name'] ?? 'Paket', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(widget.packageData['description'] ?? '', style: const TextStyle(color: Colors.black54, height: 1.5)),
                  const SizedBox(height: 16),
                  Text(currencyFormat.format(price), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPink, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- PILIH TANGGAL ACARA ---
            const Text('Tanggal Acara *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(selectedDate == null ? 'Pilih tanggal acara' : DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate!), style: TextStyle(color: selectedDate == null ? Colors.black38 : Colors.black87, fontSize: 16)),
                    const Icon(Icons.calendar_today, color: AppColors.primaryPink, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- CATATAN ---
            const Text('Catatan untuk Vendor (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Misal: Tema warna pastel, acara mulai jam 09:00 pagi...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryPink)),
              ),
            ),
            const SizedBox(height: 40),

            // --- TOMBOL LANJUT PEMBAYARAN ---
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () {
                  // Validasi: Cegah lanjut jika tanggal belum dipilih
                  if (selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan pilih tanggal acara terlebih dahulu!'), backgroundColor: Colors.red));
                    return;
                  }

                  // ---> INI BAGIAN YANG MEMPERBAIKI ERROR ANDA <---
                  // Mengirimkan semua data yang diminta oleh PaymentScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        vendorId: widget.vendorId,
                        packageId: widget.packageId,
                        packageName: widget.packageData['name'] ?? 'Paket',
                        totalPrice: price,
                        eventDate: DateFormat('yyyy-MM-dd').format(selectedDate!),
                      ),
                    ),
                  );
                },
                child: const Text('Lanjut ke Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}