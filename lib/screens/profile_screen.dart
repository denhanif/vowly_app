import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import 'edit_profile_screen.dart';
import 'help_center_screen.dart'; 
import 'vendor_bank_account_screen.dart';
import 'vendor_agreement_screen.dart'; 
import 'vendor_document_screen.dart';  
import 'notification_screen.dart'; 
import 'vendor_package_screen.dart'; // <-- PENTING: Import Halaman Layanan

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    String formatPendapatanRingkas(int amount) {
      if (amount >= 1000000) {
        double inMillions = amount / 1000000;
        return 'Rp ${inMillions.toStringAsFixed(inMillions.truncateToDouble() == inMillions ? 0 : 1)}jt';
      }
      return currencyFormat.format(amount);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        title: const Text('Profil Vendor', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: currentUser == null 
        ? const Center(child: Text("Silakan login terlebih dahulu"))
        : FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
              
              String namaLengkap = 'Vendor Vowly';
              String userRole = 'customer';
              String kategori = 'Event Organizer';
              String alamat = 'Alamat belum diatur';
              Timestamp? createdAt;

              if (snapshot.hasData && snapshot.data!.exists) {
                Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
                namaLengkap = userData['name'] ?? namaLengkap;
                userRole = userData['role'] ?? 'customer';
                kategori = userData['category'] ?? kategori;
                alamat = userData['address'] ?? alamat;
                createdAt = userData['createdAt'] as Timestamp?;
              }
              
              String joinDate = createdAt != null ? DateFormat('MMM yyyy').format(createdAt.toDate()) : 'Baru';

              if (userRole != 'vendor') {
                return _buildCustomerProfile(context, namaLengkap, currentUser.email ?? '');
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER VENDOR ---
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(color: const Color(0xFFFDE8EE), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.storefront, color: AppColors.primaryPink, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(namaLengkap, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('$kategori · $alamat', style: const TextStyle(color: Colors.black54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Row(
                                  children: const [
                                    Icon(Icons.star, color: Colors.amber, size: 14),
                                    SizedBox(width: 4),
                                    Text('4.9 · 47 ulasan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                            child: const Text('Terverifikasi', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    
                    // --- STATISTIK ---
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('orders')
                          .where('vendorId', isEqualTo: currentUser.uid)
                          .where('status', isEqualTo: 'Selesai')
                          .snapshots(),
                      builder: (context, orderSnapshot) {
                        int pesananSelesai = 0;
                        int totalPendapatan = 0;

                        if (orderSnapshot.hasData) {
                          pesananSelesai = orderSnapshot.data!.docs.length;
                          for (var doc in orderSnapshot.data!.docs) {
                            var orderData = doc.data() as Map<String, dynamic>;
                            totalPendapatan += (orderData['totalPrice'] ?? 0) as int;
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn(pesananSelesai.toString(), 'Pesanan Selesai'),
                              _buildStatColumn(formatPendapatanRingkas(totalPendapatan), 'Total Pendapatan'),
                              _buildStatColumn(joinDate, 'Bergabung'),
                            ],
                          ),
                        );
                      }
                    ),
                    Container(height: 8, color: Colors.grey.shade100),

                    // --- PAKET LAYANAN PREVIEW ---
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Paket Layanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54)),
                              
                              // ---> INI DIA TOMBOL KELOLA LAYANANNYA <---
                              TextButton.icon(
                                onPressed: () {
                                  // Navigasi ke halaman VendorPackageScreen
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const VendorPackageScreen()));
                                }, 
                                icon: const Icon(Icons.edit_note, color: AppColors.primaryPink, size: 18), 
                                label: const Text('Kelola', style: TextStyle(color: AppColors.primaryPink, fontWeight: FontWeight.bold))
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('packages').where('vendorId', isEqualTo: currentUser.uid).limit(2).snapshots(),
                            builder: (context, pkgSnapshot) {
                              if (!pkgSnapshot.hasData || pkgSnapshot.data!.docs.isEmpty) return const Text('Belum ada paket. Silakan tambah.', style: TextStyle(color: Colors.black54));
                              return Column(
                                children: pkgSnapshot.data!.docs.map((doc) {
                                  var pkg = doc.data() as Map<String, dynamic>;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(pkg['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 4),
                                              Text(pkg['description'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                            ],
                                          ),
                                        ),
                                        Text(currencyFormat.format(pkg['price'] ?? 0), style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const Icon(Icons.chevron_right, color: Colors.black54)
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                          )
                        ],
                      ),
                    ),
                    Container(height: 8, color: Colors.grey.shade100),

                    // --- PENGATURAN AKUN ---
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pengaturan Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54)),
                          const SizedBox(height: 8),
                          _buildProfileMenu(Icons.description_outlined, 'Dokumen & Legalitas', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VendorDocumentScreen()))),
                          _buildProfileMenu(Icons.account_balance_outlined, 'Rekening Bank', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VendorBankAccountScreen()))),
                          _buildProfileMenu(Icons.notifications_outlined, 'Notifikasi', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()))),
                          _buildProfileMenu(Icons.handshake_outlined, 'Perjanjian Vendor', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VendorAgreementScreen()))),
                          _buildProfileMenu(Icons.help_outline, 'Pusat Bantuan', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()))),
                          _buildProfileMenu(Icons.logout, 'Keluar', () async {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                          }, isLogout: true),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  Widget _buildProfileMenu(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isLogout ? Colors.red : AppColors.primaryPink),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.red : Colors.black87, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.black38),
      onTap: onTap,
    );
  }

  // Tampilan Profil Lama untuk Customer
  Widget _buildCustomerProfile(BuildContext context, String nama, String email) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const CircleAvatar(radius: 50, backgroundColor: AppColors.primaryPink, child: Icon(Icons.person, size: 50, color: Colors.white)),
          const SizedBox(height: 16),
          Text(nama, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(email, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 30),
          _buildProfileMenu(Icons.edit, 'Edit Profil', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()))),
          _buildProfileMenu(Icons.help_outline, 'Pusat Bantuan', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()))),
          const Divider(height: 40),
          _buildProfileMenu(Icons.logout, 'Keluar', () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
          }, isLogout: true),
        ],
      ),
    );
  }
}