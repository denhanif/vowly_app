import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // Tambahan import untuk Timeout
import '../utils/colors.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isLoading = false;

  Future<void> _selectRole(String role) async {
    setState(() { _isLoading = true; });
    
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // --- PERBAIKAN: Menambahkan Batas Waktu (Timeout) 10 Detik ---
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'role': role,
        }, SetOptions(merge: true)).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            // Jika 10 detik tidak ada respon dari Firebase (karena tidak ada internet)
            throw TimeoutException("Koneksi lambat atau terputus. Pastikan internet Anda aktif.");
          },
        );
        
        if (mounted) {
          if (role == 'vendor') {
            Navigator.pushReplacementNamed(context, '/vendor_main');
          } else {
            Navigator.pushReplacementNamed(context, '/main');
          }
        }
      } catch (e) {
        if (mounted) {
          // Menangkap error Timeout atau error lainnya
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red)
          );
        }
      }
    }
    
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Pilih Peran Anda', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  const Text('Sesuaikan pengalaman aplikasi dengan kebutuhan Anda.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 40),
                  
                  _buildRoleCard(
                    title: 'Saya ingin memesan jasa',
                    subtitle: 'Cari vendor, bandingkan harga, dan wujudkan acara impian Anda.',
                    icon: Icons.search,
                    onTap: () => _selectRole('customer'),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildRoleCard(
                    title: 'Saya adalah Vendor / EO',
                    subtitle: 'Tawarkan jasa Anda, kelola pesanan, dan temukan lebih banyak klien.',
                    icon: Icons.storefront,
                    onTap: () => _selectRole('vendor'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildRoleCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE56B8B), width: 2),
          boxShadow: [
            BoxShadow(color: const Color(0xFFE56B8B).withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(radius: 30, backgroundColor: const Color(0xFFFDE8EE), child: Icon(icon, size: 30, color: const Color(0xFFE56B8B))),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5)),
          ],
        ),
      ),
    );
  }
}