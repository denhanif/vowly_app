import 'package:flutter/material.dart';
import '../utils/colors.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Daftar semua kategori
    final List<Map<String, dynamic>> allCategories = [
      {'icon': Icons.camera_alt, 'label': 'Fotografer'},
      {'icon': Icons.mail, 'label': 'Undangan'},
      {'icon': Icons.celebration, 'label': 'Dekorasi'},
      {'icon': Icons.restaurant, 'label': 'Catering'},
      {'icon': Icons.speaker, 'label': 'Musisi'},
      {'icon': Icons.checkroom, 'label': 'Desainer'},
      {'icon': Icons.local_florist, 'label': 'Florist'},
      {'icon': Icons.face_retouching_natural, 'label': 'Makeup Artist'},
      {'icon': Icons.cake, 'label': 'Cake'}, // Tambahan kategori
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () {
            Navigator.pop(context); // Fungsi untuk kembali ke halaman sebelumnya
          },
        ),
        title: const Text(
          'Kategori',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // --- Search Bar Khusus Kategori ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari Kategori',
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.black38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // --- Grid Semua Kategori ---
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 kolom sesuai desain Anda
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 25,
                  ),
                  itemCount: allCategories.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF7EBEF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(allCategories[index]['icon'], color: Colors.black87, size: 32),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          allCategories[index]['label'],
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}