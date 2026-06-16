import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';

class EditPackageScreen extends StatefulWidget {
  final String packageId;
  final Map<String, dynamic> currentData;

  const EditPackageScreen({super.key, required this.packageId, required this.currentData});

  @override
  State<EditPackageScreen> createState() => _EditPackageScreenState();
}

class _EditPackageScreenState extends State<EditPackageScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Mengisi kolom teks dengan data yang sudah ada sebelumnya
    _nameController = TextEditingController(text: widget.currentData['name']);
    _descController = TextEditingController(text: widget.currentData['description']);
    _priceController = TextEditingController(text: widget.currentData['price'].toString());
  }

  Future<void> _updatePackage() async {
    if (_nameController.text.isEmpty || _descController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua kolom wajib diisi!'), backgroundColor: Colors.red));
      return;
    }

    setState(() { _isLoading = true; });

    try {
      await FirebaseFirestore.instance.collection('packages').doc(widget.packageId).update({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': int.parse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), '')),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paket berhasil diperbarui!'), backgroundColor: Colors.green));
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memperbarui paket.'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Edit Layanan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nama Paket / Layanan', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _nameController, decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
            const SizedBox(height: 20),
            
            const Text('Deskripsi Lengkap', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _descController, maxLines: 4, decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
            const SizedBox(height: 20),
            
            const Text('Harga (Rp)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
            const SizedBox(height: 40),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: _isLoading ? null : _updatePackage,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}