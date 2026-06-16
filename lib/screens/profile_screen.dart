import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';
import 'edit_profile_screen.dart';
import 'help_center_screen.dart'; 

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil User yang sedang login saat ini
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        title: const Text('Profil Saya', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: currentUser == null 
        ? const Center(child: Text("Silakan login terlebih dahulu"))
        : FutureBuilder<DocumentSnapshot>(
            // Membaca data dari tabel 'users' berdasarkan UID pengguna
            future: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get(),
            builder: (context, snapshot) {
              
              // Jika masih proses mengambil data
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
              }

              // Jika terjadi error
              if (snapshot.hasError) {
                return const Center(child: Text('Terjadi kesalahan saat memuat data.'));
              }

              // Mengambil data dari Firestore
              String namaLengkap = 'Pengguna Vowly';
              String infoTambahan = currentUser.email ?? '';

              if (snapshot.hasData && snapshot.data!.exists) {
                Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
                namaLengkap = userData['name'] ?? namaLengkap;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const CircleAvatar(radius: 50, backgroundColor: AppColors.primaryPink, child: Icon(Icons.person, size: 50, color: Colors.white)),
                    const SizedBox(height: 16),
                    
                    // --- NAMA & EMAIL DINAMIS ---
                    Text(namaLengkap, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(infoTambahan, style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 30),
                    // ----------------------------
                    
                    _buildProfileMenu(Icons.edit, 'Edit Profil', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                    }),
                    _buildProfileMenu(Icons.lock_outline, 'Ganti Kata Sandi', () {}),
                    _buildProfileMenu(Icons.help_outline, 'Pusat Bantuan', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()));
                    }),
                    const Divider(height: 40),
                    _buildProfileMenu(Icons.logout, 'Keluar', () async {
                      // Proses Logout dari Firebase
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    }, isLogout: true),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildProfileMenu(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.black87),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.red : Colors.black87, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
      onTap: onTap,
    );
  }
}