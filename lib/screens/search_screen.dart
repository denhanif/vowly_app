import 'package:flutter/material.dart';
import '../utils/colors.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Cari Vendor, Paket, atau Layanan...',
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.close, color: Colors.black54), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pencarian Terakhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [
                _buildSearchChip('Dekorasi Rustic'),
                _buildSearchChip('Catering Solo'),
                _buildSearchChip('Fotografer'),
              ],
            ),
            const SizedBox(height: 30),
            const Text('Pencarian Populer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ListTile(leading: const Icon(Icons.trending_up, color: Color(0xFFE56B8B)), title: const Text('Paket Wedding Lengkap'), onTap: () {}),
            ListTile(leading: const Icon(Icons.trending_up, color: Color(0xFFE56B8B)), title: const Text('Gedung Pernikahan Surakarta'), onTap: () {}),
            ListTile(leading: const Icon(Icons.trending_up, color: Color(0xFFE56B8B)), title: const Text('Makeup Artist Hijab'), onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.grey.shade200,
      deleteIcon: const Icon(Icons.close, size: 14),
      onDeleted: () {},
    );
  }
}