import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart'; // Disesuaikan dengan struktur folder kita

class VendorBankAccountScreen extends StatefulWidget {
  const VendorBankAccountScreen({super.key});

  @override
  State<VendorBankAccountScreen> createState() => _VendorBankAccountScreenState();
}

class _VendorBankAccountScreenState extends State<VendorBankAccountScreen> {
  Map<String, dynamic>? bankAccount;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBankAccount();
  }

  // MENGAMBIL DATA DARI FIRESTORE (Bukan dari Localhost)
  Future<void> loadBankAccount() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists && (userDoc.data() as Map<String, dynamic>).containsKey('bankAccount')) {
          setState(() {
            // Mengambil field 'bankAccount' dari profil vendor
            bankAccount = (userDoc.data() as Map<String, dynamic>)['bankAccount'];
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Bank Account Error: $e');
      setState(() => isLoading = false);
    }
  }

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
        title: const Text(
          'Rekening Bank',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // --- KARTU INFORMASI REKENING ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.account_balance, color: AppColors.primaryPink),
                            SizedBox(width: 8),
                            Text(
                              'Rekening Aktif',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        const Text('Bank', style: TextStyle(color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text(
                          bankAccount?['bankName'] ?? 'Belum tersedia',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        
                        const Text('Nomor Rekening', style: TextStyle(color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text(
                          bankAccount?['accountNumber'] ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        
                        const Text('Nama Pemilik', style: TextStyle(color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text(
                          bankAccount?['accountHolder'] ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // --- TOMBOL UBAH REKENING ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPink,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitur edit rekening segera tersedia')),
                        );
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text('Ubah Rekening', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}