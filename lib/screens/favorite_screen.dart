import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../providers/app_provider.dart'; // Import provider

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Memanggil data favorit dari otak aplikasi
    final appProvider = Provider.of<AppProvider>(context);
    final favorites = appProvider.favoriteVendors;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        title: const Text('Vendor Favorit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      // Tampilkan teks jika kosong, tampilkan grid jika ada isinya
      body: favorites.isEmpty
          ? const Center(
              child: Text(
                'Belum ada vendor favorit yang disimpan.',
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final vendor = favorites[index];
                return Container(
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
                  child: Stack(
                    children: [
                      const Center(child: Icon(Icons.image, color: Colors.white54, size: 40)),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () {
                            // Menghapus dari favorit saat tombol di-klik
                            appProvider.toggleFavorite(vendor);
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 40,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha : 0.6),
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                          ),
                          child: Text(
                            vendor['name'], 
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}