import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'category_detail_screen.dart';

class CategoryListScreen extends StatelessWidget {
  CategoryListScreen({super.key});

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.camera_alt, 'label': 'Fotografer'},
    {'icon': Icons.local_florist, 'label': 'Florist'},
    {'icon': Icons.face_retouching_natural, 'label': 'Makeup Artist'},
    {'icon': Icons.celebration, 'label': 'Dekorasi'},
    {'icon': Icons.restaurant, 'label': 'Catering'},
    {'icon': Icons.mail, 'label': 'Undangan'},
    {'icon': Icons.speaker, 'label': 'Musisi'},
    {'icon': Icons.checkroom, 'label': 'Desainer'},
    {'icon': Icons.videocam, 'label': 'Videografer'},
    {'icon': Icons.directions_car, 'label': 'Transportasi'},
    {'icon': Icons.cake, 'label': 'Kue Pernikahan'},
    {'icon': Icons.card_giftcard, 'label': 'Souvenir'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Semua Kategori', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.8, crossAxisSpacing: 15, mainAxisSpacing: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryDetailScreen(categoryName: categories[index]['label']))),
            child: Column(
              children: [
                Container(height: 70, width: 70, decoration: const BoxDecoration(color: Color(0xFFF7EBEF), shape: BoxShape.circle), child: Icon(categories[index]['icon'], color: Colors.black87, size: 32)),
                const SizedBox(height: 10),
                Text(categories[index]['label'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        },
      ),
    );
  }
}