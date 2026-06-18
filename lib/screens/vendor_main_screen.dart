import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'vendor_home_screen.dart';
import 'vendor_order_screen.dart';
import 'vendor_revenue_screen.dart'; // <-- Import Halaman Pendapatan
import 'vendor_chat_screen.dart';    // <-- Import Halaman Chat
import 'profile_screen.dart';

class VendorMainScreen extends StatefulWidget {
  const VendorMainScreen({super.key});

  @override
  State<VendorMainScreen> createState() => _VendorMainScreenState();
}

class _VendorMainScreenState extends State<VendorMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const VendorHomeScreen(),
    const VendorOrderScreen(),
    const VendorRevenueScreen(),
    const VendorChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryPink,
        unselectedItemColor: Colors.black45,
        showUnselectedLabels: true,
        selectedFontSize: 11, // Dikecilkan sedikit agar 5 menu muat dengan rapi
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'Pendapatan'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}