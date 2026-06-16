import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  // Daftar untuk menyimpan vendor favorit
  final List<Map<String, dynamic>> _favoriteVendors = [];

  List<Map<String, dynamic>> get favoriteVendors => _favoriteVendors;

  // Fungsi untuk menambah atau menghapus dari favorit
  void toggleFavorite(Map<String, dynamic> vendor) {
    // Cek apakah vendor sudah ada di daftar favorit
    final existingIndex = _favoriteVendors.indexWhere((v) => v['name'] == vendor['name']);
    
    if (existingIndex >= 0) {
      _favoriteVendors.removeAt(existingIndex); // Jika ada, hapus
    } else {
      _favoriteVendors.add(vendor); // Jika belum, tambahkan
    }
    notifyListeners(); // Memperbarui semua halaman yang menggunakan data ini
  }

  // Fungsi untuk mengecek status favorit (true/false)
  bool isFavorite(String vendorName) {
    return _favoriteVendors.any((v) => v['name'] == vendorName);
  }
}