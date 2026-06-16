import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'vendor_home_screen.dart';
import 'vendor_order_screen.dart';
import 'vendor_package_screen.dart';
import 'profile_screen.dart'; // Kita gunakan profil yang sama sementara

class VendorMainScreen extends StatefulWidget {
  const VendorMainScreen({super.key});

  @override
  State<VendorMainScreen> createState() => _VendorMainScreenState();
}

class _VendorMainScreenState extends State<VendorMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const VendorHomeScreen(),
    const VendorOrderScreen(),
    const VendorPackageScreen(),
    const ProfileScreen(), // Profil vendor
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFE56B8B),
        unselectedItemColor: Colors.black54,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Layanan'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Toko Saya'),
        ],
      ),
    );
  }
}