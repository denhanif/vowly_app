import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'vendor_detail_screen.dart';

class VendorListScreen extends StatelessWidget {
  const VendorListScreen({super.key});

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
        title: const Text('Semua Vendor', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.9, crossAxisSpacing: 16, mainAxisSpacing: 16,
        ),
        itemCount: 8, // Contoh 8 vendor
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VendorDetailScreen()));
            },
            child: Container(
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(height: 60, decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)), gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withValues(alpha : 0.8), Colors.transparent]))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)), child: const Text('Vendor', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold))),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Nama Vendor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: const [Icon(Icons.star, color: Colors.amber, size: 12), SizedBox(width: 4), Text('4.9', style: TextStyle(color: Colors.white, fontSize: 10))]),
                                Row(children: const [Icon(Icons.favorite, color: Colors.white, size: 12), SizedBox(width: 4), Text('347', style: TextStyle(color: Colors.white, fontSize: 10))]),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}