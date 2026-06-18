import 'package:flutter/material.dart';
import '../utils/colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

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
        title: const Text('Notifikasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryPink.withValues(alpha :0.2),
              child: const Icon(Icons.notifications, color: Color(0xFFE56B8B)),
            ),
            title: const Text('Promo Spesial Hari Ini!', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Dapatkan diskon 20% untuk pemesanan Wedding Organizer.'),
            trailing: const Text('10:00', style: TextStyle(color: Colors.black54, fontSize: 12)),
          );
        },
      ),
    );
  }
}