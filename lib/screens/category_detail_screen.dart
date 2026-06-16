import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'vendor_detail_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;

  const CategoryDetailScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text('Vendor $categoryName', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _buildFilterChip('Terpopuler', true),
                const SizedBox(width: 10),
                _buildFilterChip('Harga Terendah', false),
                const SizedBox(width: 10),
                _buildFilterChip('Rating Tertinggi', false),
                const SizedBox(width: 10),
                _buildFilterChip('Terdekat', false),
              ],
            ),
          ),
          // Daftar Vendor
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 5,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VendorDetailScreen())),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    height: 120,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                    child: Row(
                      children: [
                        Container(width: 110, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)))),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Vendor $categoryName ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    const Text('Surakarta', style: TextStyle(color: Colors.black54, fontSize: 12)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: const [Icon(Icons.star, color: Colors.amber, size: 14), SizedBox(width: 4), Text('4.9', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))]),
                                    const Text('Rp 5.000.000', style: TextStyle(color: Color(0xFFE56B8B), fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Chip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
      backgroundColor: isSelected ? const Color(0xFFE56B8B) : Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
    );
  }
}